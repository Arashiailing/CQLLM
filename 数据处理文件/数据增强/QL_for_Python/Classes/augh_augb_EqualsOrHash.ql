/**
 * @name Inconsistent equality and hashing
 * @description Classes defining equality without hashability (or vice-versa) violate object model contracts
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

// Checks whether a class implements equality comparison methods
CallableValue hasEqualityMethod(ClassValue targetClass, string methodName) {
  // Verify presence of __eq__ in all Python versions or __cmp__ in Python 2
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(methodName)
}

// Retrieves methods implemented for equality comparison or hashing
CallableValue getImplementedMethod(ClassValue targetClass, string methodName) {
  // Obtain either equality methods or __hash__ implementation
  result = hasEqualityMethod(targetClass, methodName)
  or
  result = targetClass.declaredAttribute("__hash__") and methodName = "__hash__"
}

/** Determines if a class is explicitly marked as unhashable */
predicate isUnhashable(ClassValue targetClass) {
  // Check if __hash__ is explicitly set to None or if it never returns
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Identifies methods that are missing in a class implementation
string getMissingMethod(ClassValue targetClass) {
  // Detect missing equality methods based on Python version
  not exists(hasEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Detect missing __hash__ in Python 2 (Python 3 handles this automatically)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

// Identifies classes that violate the hash contract implementation
predicate violatesHashContract(ClassValue targetClass, string implementedMethod, string missingMethod, Value foundMethod) {
  // Exclude classes that are explicitly unhashable or have failed inference
  not isUnhashable(targetClass) and
  not targetClass.failedInference(_) and
  // Verify that a method is implemented while another is missing
  missingMethod = getMissingMethod(targetClass) and
  foundMethod = getImplementedMethod(targetClass, implementedMethod)
}

// Main query: Detects classes with inconsistent equality and hashing implementations
from ClassValue targetClass, string implementedMethod, string missingMethod, CallableValue foundMethod
where
  violatesHashContract(targetClass, implementedMethod, missingMethod, foundMethod) and
  exists(targetClass.getScope()) // Exclude classes not defined in source code
select foundMethod, "Class $@ implements " + implementedMethod + " but does not define " + missingMethod + ".", targetClass,
  targetClass.getName()