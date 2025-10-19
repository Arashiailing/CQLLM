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

/** Determines if class implements equality comparison methods */
CallableValue implementsEqualityMethod(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

/** Checks if class implements specified special method */
CallableValue implementsSpecialMethod(ClassValue cls, string methodName) {
  result = implementsEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

/** Identifies missing method names in class implementation */
string getMissingMethodName(ClassValue cls) {
  not exists(implementsEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Python 3 makes classes unhashable when __eq__ exists but __hash__ doesn't
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Determines if class is explicitly unhashable */
predicate isExplicitlyUnhashable(ClassValue cls) {
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

/** Detects violations of hash contract requirements */
predicate hasHashContractViolation(ClassValue cls, string presentMethod, string missingMethod, Value m) {
  not isExplicitlyUnhashable(cls) and
  missingMethod = getMissingMethodName(cls) and
  m = implementsSpecialMethod(cls, presentMethod) and
  not cls.failedInference(_)
}

// Select classes violating hash contract with diagnostic info
from ClassValue cls, string presentMethod, string missingMethod, CallableValue m
where
  hasHashContractViolation(cls, presentMethod, missingMethod, m) and
  exists(cls.getScope()) // Ensure results originate from source code
select m, "Class $@ implements " + presentMethod + " but lacks " + missingMethod + " definition.", cls,
  cls.getName()