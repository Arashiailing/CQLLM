/**
 * @name Inconsistent equality and hashing
 * @description Detects classes violating object model contracts by implementing equality without hashability or vice versa
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

// Identify equality comparison methods in class definitions
CallableValue checkEqualityMethod(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Check if class implements specific special methods
CallableValue checkImplementedMethod(ClassValue cls, string methodName) {
  result = checkEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determine missing method names in class implementation
string getMissingMethodName(ClassValue cls) {
  not exists(checkEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Python 3 automatically makes classes unhashable when __eq__ exists without __hash__
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Check if class is explicitly marked as unhashable */
predicate isExplicitlyUnhashable(ClassValue cls) {
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Identify classes violating hash contract requirements
predicate checkHashContractViolation(ClassValue cls, string presentMethod, string missingMethod, Value m) {
  not isExplicitlyUnhashable(cls) and
  missingMethod = getMissingMethodName(cls) and
  m = checkImplementedMethod(cls, presentMethod) and
  not cls.failedInference(_)
}

// Select classes violating hash contract with diagnostic details
from ClassValue cls, string presentMethod, string missingMethod, CallableValue m
where
  checkHashContractViolation(cls, presentMethod, missingMethod, m) and
  exists(cls.getScope()) // Ensure results originate from source code
select m, "Class $@ implements " + presentMethod + " but lacks " + missingMethod + " definition.", cls,
  cls.getName()