/**
 * @name Inconsistent equality and hashing
 * @description Defining equality for a class without also defining hashability (or vice-versa) violates the object model.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-581
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/equals-hash-mismatch
 */

import python

// Identifies equality comparison methods in a class
CallableValue definesEqualityMethod(ClassValue targetClass, string methodName) {
  // Check for __eq__ method or Python 2's __cmp__
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(methodName)
}

// Retrieves implemented methods from a class
CallableValue findImplementedMethod(ClassValue targetClass, string methodName) {
  // Return equality methods or __hash__ implementation
  result = definesEqualityMethod(targetClass, methodName)
  or
  result = targetClass.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determines which method is missing in a class
string determineMissingMethodName(ClassValue targetClass) {
  // Case 1: Equality methods missing
  not exists(definesEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: __hash__ method missing (Python 2 specific)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Indicates if a class is intentionally unhashable */
predicate isUnhashable(ClassValue targetClass) {
  // Class is unhashable if __hash__ is explicitly None or never returns
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects classes violating the hash contract
predicate hasHashContractViolation(ClassValue targetClass, string existingMethod, string missingMethod, Value methodImpl) {
  // Verify class isn't intentionally unhashable and has missing methods
  not isUnhashable(targetClass) and
  missingMethod = determineMissingMethodName(targetClass) and
  methodImpl = findImplementedMethod(targetClass, existingMethod) and
  not targetClass.failedInference(_) // Exclude classes with inference failures
}

// Main query identifying classes with hash contract violations
from ClassValue targetClass, string existingMethod, string missingMethod, CallableValue methodImpl
where
  hasHashContractViolation(targetClass, existingMethod, missingMethod, methodImpl) and
  exists(targetClass.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", targetClass,
  targetClass.getName()