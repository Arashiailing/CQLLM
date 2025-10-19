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

// Check if class implements equality comparison methods
CallableValue hasEqualityMethod(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Check if class implements specified special method
CallableValue hasImplementedMethod(ClassValue cls, string methodName) {
  result = hasEqualityMethod(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Identify missing method names in class implementation
string missingMethodName(ClassValue cls) {
  not exists(hasEqualityMethod(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Python 3 makes classes unhashable when __eq__ exists but __hash__ doesn't
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Determine if class is explicitly unhashable */
predicate isUnhashable(ClassValue cls) {
  cls.lookup("__hash__") = Value::named("None")
  or
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect violations of hash contract requirements
predicate violatesHashContract(ClassValue cls, string presentMethod, string missingMethod, Value m) {
  not isUnhashable(cls) and
  missingMethod = missingMethodName(cls) and
  m = hasImplementedMethod(cls, presentMethod) and
  not cls.failedInference(_)
}

// Select classes violating hash contract with diagnostic info
from ClassValue cls, string presentMethod, string missingMethod, CallableValue m
where
  violatesHashContract(cls, presentMethod, missingMethod, m) and
  exists(cls.getScope()) // Ensure results originate from source code
select m, "Class $@ implements " + presentMethod + " but lacks " + missingMethod + " definition.", cls,
  cls.getName()