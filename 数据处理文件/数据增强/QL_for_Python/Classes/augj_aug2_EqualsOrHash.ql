/**
 * @name Inconsistent equality and hashing
 * @description Detects classes that violate the object contract by implementing equality without hashability (or vice-versa)
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

/** Determines if a class implements equality comparison methods */
CallableValue hasEqualityMethod(ClassValue targetClass, string methodName) {
  // Check for __eq__ in all Python versions or __cmp__ in Python 2
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(methodName)
}

/** Retrieves implemented methods from a class (equality or hashing) */
CallableValue getImplementedMethod(ClassValue targetClass, string methodName) {
  // Handle equality methods
  result = hasEqualityMethod(targetClass, methodName)
  or
  // Handle hash method
  result = targetClass.declaredAttribute("__hash__") and methodName = "__hash__"
}

/** Identifies missing methods in a class that violate the hash contract */
string getMissingMethodName(ClassValue targetClass) {
  // Case 1: Missing equality methods
  not exists(hasEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 specific)
  not targetClass.declaresAttribute(result) and 
  result = "__hash__" and 
  major_version() = 2
}

/** Identifies classes explicitly marked as unhashable */
predicate isUnhashable(ClassValue targetClass) {
  // Check for explicit None assignment or non-returning hash method
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

/** Detects violations of the hash contract in classes */
predicate violatesHashContract(ClassValue targetClass, string existingMethod, string missingMethod, Value methodImplementation) {
  // Exclude intentionally unhashable classes and those with inference failures
  not isUnhashable(targetClass) and
  not targetClass.failedInference(_) and
  // Identify the missing method
  missingMethod = getMissingMethodName(targetClass) and
  // Get the existing method implementation
  methodImplementation = getImplementedMethod(targetClass, existingMethod)
}

// Main query to find classes violating the hash contract
from ClassValue cls, string existingMethod, string missingMethod, CallableValue methodImpl
where
  violatesHashContract(cls, existingMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()