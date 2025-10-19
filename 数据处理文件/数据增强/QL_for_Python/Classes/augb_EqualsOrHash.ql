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

// Determines if a class implements equality comparison methods
CallableValue hasEqualityMethod(ClassValue cls, string methodName) {
  // Check for __eq__ in all versions or __cmp__ in Python 2
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Retrieves implemented methods for equality or hashing
CallableValue getImplementedMethod(ClassValue cls, string methodName) {
  // Get equality methods or __hash__ implementation
  result = hasEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Identifies missing methods in class implementation
string getMissingMethod(ClassValue cls) {
  // Detect missing equality methods based on Python version
  not exists(hasEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Detect missing __hash__ in Python 2 (Python 3 handles this automatically)
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Indicates when a class is explicitly unhashable */
predicate isUnhashable(ClassValue cls) {
  // Check if __hash__ is set to None or never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects violations of hash contract implementation
predicate violatesHashContract(ClassValue cls, string implemented, string missing, Value method) {
  // Exclude explicitly unhashable classes and failed inferences
  not isUnhashable(cls) and
  missing = getMissingMethod(cls) and
  method = getImplementedMethod(cls, implemented) and
  not cls.failedInference(_)
}

// Main query: Find classes with inconsistent equality/hash implementations
from ClassValue cls, string implemented, string missing, CallableValue method
where
  violatesHashContract(cls, implemented, missing, method) and
  exists(cls.getScope()) // Filter out non-source classes
select method, "Class $@ implements " + implemented + " but does not define " + missing + ".", cls,
  cls.getName()