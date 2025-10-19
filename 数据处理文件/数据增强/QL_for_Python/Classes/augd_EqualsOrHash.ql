/**
 * @name Inconsistent equality and hashing
 * @description Defining equality for a class without also defining hashability (or vice-versa) violates the object model.
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

// Determines if a class defines equality comparison methods (__eq__ or __cmp__)
CallableValue defines_equality(ClassValue cls, string methodName) {
  // Check for Python 3's __eq__ or Python 2's __cmp__ method
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = cls.declaredAttribute(methodName)
}

// Retrieves implemented equality or hashing methods from a class
CallableValue implemented_method(ClassValue cls, string methodName) {
  // Return equality method if defined
  result = defines_equality(cls, methodName)
  or
  // Return hash method if defined
  result = cls.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Identifies missing equality or hashing methods in a class
string unimplemented_method(ClassValue cls) {
  // Case 1: Missing equality methods
  not exists(defines_equality(cls, _)) and
  (
    // Python 3 requires __eq__
    result = "__eq__" and major_version() = 3
    or
    // Python 2 requires either __eq__ or __cmp__
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing hash method (Python 2 only)
  // Python 3 automatically makes classes unhashable when __eq__ exists without __hash__
  not cls.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Identifies classes that are explicitly unhashable */
predicate unhashable(ClassValue cls) {
  // Check if __hash__ is set to None
  cls.lookup("__hash__") = Value::named("None")
  or
  // Check if __hash__ method never returns a value
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects violations of the hash contract where equality/hash methods are inconsistent
predicate violates_hash_contract(ClassValue cls, string presentMethod, string missingMethod, Value methodImpl) {
  // Exclude explicitly unhashable classes
  not unhashable(cls) and
  // Identify the missing method
  missingMethod = unimplemented_method(cls) and
  // Identify the implemented method
  methodImpl = implemented_method(cls, presentMethod) and
  // Exclude classes with failed type inference
  not cls.failedInference(_)
}

// Main query to find classes violating the hash contract
from ClassValue cls, string presentMethod, string missingMethod, CallableValue methodImpl
where
  violates_hash_contract(cls, presentMethod, missingMethod, methodImpl) and
  exists(cls.getScope()) // Only include classes from source code
select methodImpl, "Class $@ implements " + presentMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()