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

/** Checks if a class implements equality comparison methods */
CallableValue hasEqualityMethod(ClassValue cls, string method) {
  // Verify presence of __eq__ in all Python versions or __cmp__ in Python 2
  (
    method = "__eq__"
    or
    major_version() = 2 and method = "__cmp__"
  ) and
  result = cls.declaredAttribute(method)
}

/** Retrieves implemented equality or hashing methods */
CallableValue getImplementedMethod(ClassValue cls, string method) {
  // Obtain either equality methods or __hash__ implementation
  result = hasEqualityMethod(cls, method)
  or
  result = cls.declaredAttribute("__hash__") and method = "__hash__"
}

/** Determines if a class is explicitly marked as unhashable */
predicate isUnhashable(ClassValue cls) {
  // Check if __hash__ is explicitly set to None or if it never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

/** Identifies methods missing in a class implementation */
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

/** Identifies classes violating hash contract implementation */
predicate violatesHashContract(ClassValue cls, string implMethod, string missing, Value implMethodValue) {
  // Exclude classes that are explicitly unhashable or have failed inference
  not isUnhashable(cls) and
  not cls.failedInference(_) and
  // Verify that a method is implemented while another is missing
  missing = getMissingMethod(cls) and
  implMethodValue = getImplementedMethod(cls, implMethod)
}

// Main query: Detects classes with inconsistent equality and hashing implementations
from ClassValue cls, string implMethod, string missing, CallableValue implMethodValue
where
  violatesHashContract(cls, implMethod, missing, implMethodValue) and
  exists(cls.getScope()) // Exclude classes not defined in source code
select implMethodValue, "Class $@ implements " + implMethod + " but does not define " + missing + ".", cls,
  cls.getName()