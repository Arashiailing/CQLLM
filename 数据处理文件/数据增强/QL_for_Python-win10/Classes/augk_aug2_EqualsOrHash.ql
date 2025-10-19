/**
 * @name Inconsistent equality and hashing
 * @description Classes defining equality without hashability (or vice-versa) violate the object contract
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

// Checks if a class implements equality comparison methods
CallableValue definesEqualityMethod(ClassValue targetClass, string methodNameToCheck) {
  // Supports both __eq__ and Python 2's __cmp__
  (
    methodNameToCheck = "__eq__"
    or
    major_version() = 2 and methodNameToCheck = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(methodNameToCheck)
}

// Retrieves method implementations from a class
CallableValue getMethodImplementation(ClassValue targetClass, string methodNameToCheck) {
  // Returns equality methods or __hash__ implementation
  result = definesEqualityMethod(targetClass, methodNameToCheck)
  or
  result = targetClass.declaredAttribute("__hash__") and methodNameToCheck = "__hash__"
}

// Identifies missing methods in a class
string determineMissingMethod(ClassValue targetClass) {
  // Case 1: Equality methods are missing
  not exists(definesEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: __hash__ is missing (Python 2 specific)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Detects intentionally unhashable classes */
predicate isExplicitlyUnhashable(ClassValue targetClass) {
  // Class marked unhashable via None assignment or non-returning __hash__
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Core logic for hash contract violations
predicate violatesObjectContract(ClassValue targetClass, string existingMethodName, string missingMethodName, Value methodImplementation) {
  // Exclude intentionally unhashable classes and inference failures
  not isExplicitlyUnhashable(targetClass) and
  missingMethodName = determineMissingMethod(targetClass) and
  methodImplementation = getMethodImplementation(targetClass, existingMethodName) and
  not targetClass.failedInference(_)
}

// Main query detecting contract violations
from ClassValue targetClass, string existingMethodName, string missingMethodName, CallableValue methodImplementation
where
  violatesObjectContract(targetClass, existingMethodName, missingMethodName, methodImplementation) and
  exists(targetClass.getScope()) // Ensure class is from source code
select methodImplementation, "Class $@ implements " + existingMethodName + " but omits " + missingMethodName + ".", targetClass,
  targetClass.getName()