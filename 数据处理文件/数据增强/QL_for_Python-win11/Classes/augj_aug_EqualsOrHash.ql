/**
 * @name Inconsistent equality and hashing
 * @description Classes defining equality without hashability (or vice-versa) violate object contract
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

// Check if class implements equality comparison methods
CallableValue hasEqualityMethod(ClassValue cls, string methodName) {
  // Standard equality method in all Python versions
  methodName = "__eq__" and
  result = cls.declaredAttribute(methodName)
  or
  // Legacy comparison method in Python 2
  major_version() = 2 and
  methodName = "__cmp__" and
  result = cls.declaredAttribute(methodName)
}

// Verify class implements specific method
CallableValue implementsMethod(ClassValue cls, string methodName) {
  // Handle equality methods
  result = hasEqualityMethod(cls, methodName)
  or
  // Handle hash method
  methodName = "__hash__" and
  result = cls.declaredAttribute("__hash__")
}

// Identify missing method in class implementation
string getMissingMethod(ClassValue cls) {
  // Equality methods missing
  not exists(hasEqualityMethod(cls, _)) and
  (
    // Python 3 requires __eq__
    major_version() = 3 and
    result = "__eq__"
    or
    // Python 2 accepts either __eq__ or __cmp__
    major_version() = 2 and
    result = "__eq__ or __cmp__"
  )
  or
  // Hash method missing (Python 2 only)
  major_version() = 2 and
  result = "__hash__" and
  not cls.declaresAttribute("__hash__")
}

/** Check if class is explicitly marked as unhashable */
predicate isExplicitlyUnhashable(ClassValue cls) {
  // Explicit __hash__ = None assignment
  cls.lookup("__hash__") = Value::named("None")
  or
  // __hash__ method that never returns
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect hash contract violations in class
predicate hasHashContractViolation(ClassValue cls, string existingMethod, string absentMethod, Value methodImpl) {
  // Exclude explicitly unhashable classes
  not isExplicitlyUnhashable(cls) and
  // Determine missing method
  absentMethod = getMissingMethod(cls) and
  // Get existing method implementation
  methodImpl = implementsMethod(cls, existingMethod) and
  // Exclude classes with inference failures
  not cls.failedInference(_)
}

// Main query to find violating classes
from ClassValue cls, string existingMethod, string absentMethod, CallableValue methodImpl
where
  hasHashContractViolation(cls, existingMethod, absentMethod, methodImpl) and
  exists(cls.getScope()) // Only source code classes
select methodImpl, "Class $@ implements " + existingMethod + " but does not define " + absentMethod + ".", cls,
  cls.getName()