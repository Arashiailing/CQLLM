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

// Helper function to check if a class defines equality comparison methods
CallableValue hasEqualityMethod(ClassValue cls, string methodName) {
  // Match either __eq__ method or __cmp__ in Python 2
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Helper function to retrieve implemented methods from a class
CallableValue getImplementedMethod(ClassValue cls, string methodName) {
  // Return equality methods or __hash__ implementation
  result = hasEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Helper function to identify missing methods in a class
string getMissingMethodName(ClassValue cls) {
  // Case 1: Missing equality methods
  not exists(hasEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 specific)
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Holds if this class is unhashable */
predicate isUnhashable(ClassValue cls) {
  // Class is unhashable if __hash__ is explicitly set to None or never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Core predicate to detect hash contract violations
predicate violatesHashContract(ClassValue cls, string existingMethod, string missingMethod, Value methodImpl) {
  // Check class is not intentionally unhashable and has missing methods
  not isUnhashable(cls) and
  missingMethod = getMissingMethodName(cls) and
  methodImpl = getImplementedMethod(cls, existingMethod) and
  not cls.failedInference(_) // Exclude classes with inference failures
}

// Main query to find classes violating hash contract
from ClassValue cls, string existingMethod, string missingMethod, CallableValue methodImpl
where
  violatesHashContract(cls, existingMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()