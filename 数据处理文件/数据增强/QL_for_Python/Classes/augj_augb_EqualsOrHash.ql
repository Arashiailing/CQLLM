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

// Checks if a class implements equality comparison methods
CallableValue checkEqualityMethod(ClassValue targetClass, string equalityMethodName) {
  // Verify __eq__ implementation or __cmp__ in Python 2
  (
    equalityMethodName = "__eq__"
    or
    major_version() = 2 and equalityMethodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(equalityMethodName)
}

// Retrieves implemented equality or hashing methods
CallableValue findImplementedMethod(ClassValue targetClass, string methodCategory) {
  // Get equality methods or __hash__ implementation
  result = checkEqualityMethod(targetClass, methodCategory)
  or
  result = targetClass.declaredAttribute("__hash__") and methodCategory = "__hash__"
}

// Determines missing methods in class implementation
string determineMissingMethod(ClassValue targetClass) {
  // Identify missing equality methods based on Python version
  not exists(checkEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Identify missing __hash__ in Python 2 (Python 3 handles automatically)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

// Checks if a class is explicitly unhashable
predicate isExplicitlyUnhashable(ClassValue targetClass) {
  // Verify __hash__ is set to None or never returns
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Main query: Find classes with inconsistent equality/hash implementations
from ClassValue targetClass, string implementedMethod, string missingMethod, CallableValue methodRef
where
  // Combine violation conditions from original violatesHashContract
  not isExplicitlyUnhashable(targetClass) and
  missingMethod = determineMissingMethod(targetClass) and
  methodRef = findImplementedMethod(targetClass, implementedMethod) and
  not targetClass.failedInference(_) and
  exists(targetClass.getScope()) // Filter out non-source classes
select methodRef, "Class $@ implements " + implementedMethod + " but does not define " + missingMethod + ".", targetClass,
  targetClass.getName()