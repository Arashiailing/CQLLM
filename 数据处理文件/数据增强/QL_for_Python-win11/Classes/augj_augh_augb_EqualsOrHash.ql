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

/**
 * Determines if a class implements equality comparison methods.
 * In Python 3, checks for __eq__; in Python 2, checks for __eq__ or __cmp__.
 */
CallableValue hasEqualityMethod(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

/**
 * Retrieves methods implemented for equality comparison or hashing.
 * Returns either equality methods (__eq__ or __cmp__) or __hash__ implementation.
 */
CallableValue getImplementedMethod(ClassValue cls, string methodName) {
  result = hasEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

/**
 * Determines if a class is explicitly marked as unhashable.
 * A class is unhashable if __hash__ is set to None or if it never returns.
 */
predicate isUnhashable(ClassValue cls) {
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

/**
 * Identifies methods that are missing in a class implementation.
 * In Python 3, checks for missing __eq__; in Python 2, checks for missing __eq__ or __cmp__.
 * Also checks for missing __hash__ in Python 2.
 */
string getMissingMethod(ClassValue cls) {
  not exists(hasEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/**
 * Identifies classes that violate the hash contract implementation.
 * A class violates the contract if it implements one of equality or hashing
 * but not the other, and is not explicitly marked as unhashable.
 */
predicate violatesHashContract(ClassValue cls, string implMethod, string missingMethod, Value foundMethod) {
  not isUnhashable(cls) and
  not cls.failedInference(_) and
  missingMethod = getMissingMethod(cls) and
  foundMethod = getImplementedMethod(cls, implMethod)
}

// Main query: Detects classes with inconsistent equality and hashing implementations
from ClassValue cls, string implMethod, string missingMethod, CallableValue foundMethod
where
  violatesHashContract(cls, implMethod, missingMethod, foundMethod) and
  exists(cls.getScope()) // Exclude classes not defined in source code
select foundMethod, "Class $@ implements " + implMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()