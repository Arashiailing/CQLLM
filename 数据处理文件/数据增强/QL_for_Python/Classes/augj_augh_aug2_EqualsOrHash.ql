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

// Identifies equality comparison methods defined in a class
CallableValue definesEqualityMethod(ClassValue targetClass, string methodName) {
  // Check for __eq__ method or Python 2's __cmp__ method
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(methodName)
}

// Retrieves implemented methods from a class
CallableValue getMethodImplementation(ClassValue targetClass, string methodName) {
  // Return either equality methods or __hash__ implementation
  result = definesEqualityMethod(targetClass, methodName)
  or
  result = targetClass.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determines which method is missing in a class
string getMissingMethod(ClassValue targetClass) {
  // Case 1: Missing equality comparison methods
  not exists(definesEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 specific)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Holds if this class is explicitly marked as unhashable */
predicate isExplicitlyUnhashable(ClassValue targetClass) {
  // Class is unhashable if __hash__ is set to None or never returns
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects violations of the hash contract
predicate hasHashContractViolation(ClassValue targetClass, string existingMethod, string missingMethod, Value methodImpl) {
  // Ensure class isn't intentionally unhashable and has missing methods
  not isExplicitlyUnhashable(targetClass) and
  missingMethod = getMissingMethod(targetClass) and
  methodImpl = getMethodImplementation(targetClass, existingMethod) and
  not targetClass.failedInference(_) // Exclude classes with inference failures
}

// Main query to identify classes violating the hash contract
from ClassValue cls, string existingMethod, string missingMethod, CallableValue methodImpl
where
  hasHashContractViolation(cls, existingMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()