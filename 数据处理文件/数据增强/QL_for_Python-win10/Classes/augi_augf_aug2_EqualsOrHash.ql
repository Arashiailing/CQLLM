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

// Identifies equality comparison methods within a class
CallableValue getEqualityMethod(ClassValue cls, string methodName) {
  // Check for __eq__ method or Python 2's __cmp__
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Retrieves implemented methods from a class (either equality methods or __hash__)
CallableValue getClassMethod(ClassValue cls, string methodName) {
  // Return equality methods or __hash__ implementation
  result = getEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determines which method is missing in a class to satisfy the hash contract
string getMissingMethodName(ClassValue cls) {
  // Case 1: Equality methods are missing
  not exists(getEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: __hash__ method is missing (Python 2 specific)
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Checks if a class is intentionally designed to be unhashable */
predicate isIntentionallyUnhashable(ClassValue cls) {
  // Class is unhashable if __hash__ is explicitly set to None or never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects classes that violate the hash contract by not implementing required methods
predicate violatesHashContract(ClassValue cls, string existingMethod, string missingMethod, Value methodImpl) {
  // Verify the class isn't intentionally unhashable and has missing methods
  not isIntentionallyUnhashable(cls) and
  missingMethod = getMissingMethodName(cls) and
  methodImpl = getClassMethod(cls, existingMethod) and
  not cls.failedInference(_) // Exclude classes with inference failures
}

// Main query that identifies classes with hash contract violations
from ClassValue cls, string existingMethod, string missingMethod, CallableValue methodImpl
where
  violatesHashContract(cls, existingMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()