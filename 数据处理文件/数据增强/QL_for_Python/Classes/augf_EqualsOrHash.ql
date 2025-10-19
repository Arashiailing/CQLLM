/**
 * @name Inconsistent equality and hashing
 * @description Classes defining equality without hashability (or vice-versa) violate object model contracts.
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

// Check if class implements equality comparison (__eq__ or __cmp__)
CallableValue defines_equality(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Check if class implements specified method
CallableValue implemented_method(ClassValue cls, string methodName) {
  result = defines_equality(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Identify missing methods in class implementation
string missing_method(ClassValue cls) {
  // Handle missing equality methods
  not exists(defines_equality(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Handle missing hash method in Python 2
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Holds if class is explicitly unhashable */
predicate unhashable(ClassValue cls) {
  // Class has __hash__ set to None or method never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect hash contract violations in class definitions
predicate violates_hash_contract(ClassValue cls, string implemented, string missing, Value method) {
  not unhashable(cls) and
  missing = missing_method(cls) and
  method = implemented_method(cls, implemented) and
  not cls.failedInference(_)
}

// Report classes with inconsistent equality/hash implementations
from ClassValue cls, string implemented, string missing, CallableValue method
where
  violates_hash_contract(cls, implemented, missing, method) and
  exists(cls.getScope()) // Filter out non-source classes
select method, "Class $@ implements " + implemented + " but does not define " + missing + ".", cls,
  cls.getName()