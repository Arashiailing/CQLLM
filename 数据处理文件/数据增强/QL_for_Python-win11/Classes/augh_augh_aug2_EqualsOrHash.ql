/**
 * @name Inconsistent equality and hashing
 * @description Detects classes violating the hash contract by implementing equality without hashability (or vice-versa)
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

/** Identifies equality comparison methods in a class */
CallableValue getEqualityMethod(ClassValue cls, string methodName) {
  // Check for __eq__ method or Python 2's __cmp__ method
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

/** Retrieves equality or hash method implementations from a class */
CallableValue getClassMethod(ClassValue cls, string methodName) {
  result = getEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

/** Determines which method is missing in a class */
string findMissingMethod(ClassValue cls) {
  // Case 1: Missing equality comparison methods
  not exists(getEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 specific)
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Checks if class is explicitly marked as unhashable */
predicate isUnhashable(ClassValue cls) {
  // Class is unhashable if __hash__ is set to None or never returns
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

/** Detects classes violating the hash contract */
predicate violatesHashContract(ClassValue cls, string definedMethod, string absentMethod, Value impl) {
  // Ensure class isn't intentionally unhashable
  not isUnhashable(cls) and
  // Identify missing method
  absentMethod = findMissingMethod(cls) and
  // Get existing method implementation
  impl = getClassMethod(cls, definedMethod) and
  // Exclude classes with inference failures
  not cls.failedInference(_)
}

// Main query to identify classes violating the hash contract
from ClassValue cls, string definedMethod, string absentMethod, CallableValue impl
where
  violatesHashContract(cls, definedMethod, absentMethod, impl) and
  exists(cls.getScope()) // Ensure class is from source code
select impl, "Class $@ implements " + definedMethod + " but does not define " + absentMethod + ".", cls,
  cls.getName()