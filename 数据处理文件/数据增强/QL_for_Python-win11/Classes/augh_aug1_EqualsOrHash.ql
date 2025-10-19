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

// Determine if class implements equality comparison methods
CallableValue definesEqualityMethod(ClassValue klass, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = klass.declaredAttribute(methodName)
}

// Identify classes explicitly marked as unhashable
predicate isExplicitlyUnhashable(ClassValue klass) {
  klass.lookup("__hash__") = Value::named("None")
  or
  klass.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect violations of the hash contract requirement
predicate violatesHashContract(ClassValue klass, string implementedMethod, string missingMethod, Value methodImpl) {
  not isExplicitlyUnhashable(klass) and
  not klass.failedInference(_) and
  (
    // Case 1: Missing equality methods but hash is implemented
    not exists(definesEqualityMethod(klass, _)) and
    implementedMethod = "__hash__" and
    (
      missingMethod = "__eq__" and major_version() = 3
      or
      major_version() = 2 and missingMethod = "__eq__ or __cmp__"
    ) and
    methodImpl = klass.declaredAttribute("__hash__")
    or
    // Case 2: Missing hash method (Python 2) but equality is implemented
    major_version() = 2 and
    missingMethod = "__hash__" and
    not klass.declaresAttribute("__hash__") and
    (
      implementedMethod = "__eq__" and methodImpl = definesEqualityMethod(klass, "__eq__")
      or
      implementedMethod = "__cmp__" and methodImpl = definesEqualityMethod(klass, "__cmp__")
    )
  )
}

// Select classes violating hash contract with diagnostic information
from ClassValue cls, string implementedMethod, string missingMethod, CallableValue methodImpl
where
  violatesHashContract(cls, implementedMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Ensure results originate from source code
select methodImpl, "Class $@ implements " + implementedMethod + " but lacks " + missingMethod + " definition.", cls,
  cls.getName()