/**
 * @name Inconsistent equality and hashing
 * @description A class that defines equality without defining hashability (or vice versa) violates the object model.
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

// Checks if a class defines an equality comparison method (__eq__ or __cmp__)
CallableValue defines_equality(ClassValue cls, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Checks if a class implements the specified method
CallableValue implemented_method(ClassValue cls, string methodName) {
  result = defines_equality(cls, methodName)
  or
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determines which method is not implemented by the class
string unimplemented_method(ClassValue cls) {
  not exists(defines_equality(cls, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  /* Python 3 automatically makes classes unhashable if __eq__ is defined, but __hash__ is not */
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Holds if the class is unhashable */
predicate unhashable(ClassValue classObj) {
  classObj.lookup("__hash__") = Value::named("None")
  or
  classObj.lookup("__hash__").(CallableValue).neverReturns()
}

// Holds if the class violates the hash contract by having one method without the other
predicate violates_hash_contract(ClassValue cls, string existingMethod, string missingMethod, CallableValue implementedMethod) {
  not unhashable(cls) and
  missingMethod = unimplemented_method(cls) and
  implementedMethod = implemented_method(cls, existingMethod) and
  not cls.failedInference(_)
}

from ClassValue cls, string existingMethod, string missingMethod, CallableValue implementedMethod
where
  violates_hash_contract(cls, existingMethod, missingMethod, implementedMethod) and
  exists(cls.getScope()) // Suppress results that aren't from source
select implementedMethod, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()