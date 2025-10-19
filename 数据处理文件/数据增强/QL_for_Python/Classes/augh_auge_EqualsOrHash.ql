/**
 * @name Inconsistent equality and hashing
 * @description Detects classes violating object contract by implementing equality without hashability (or vice versa)
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

// Determines if a class implements equality comparison methods (__eq__ or __cmp__)
CallableValue has_equality_method(ClassValue classObj, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = classObj.declaredAttribute(methodName)
}

// Checks if a class implements a specific method (equality or hash)
CallableValue get_implemented_method(ClassValue classObj, string methodName) {
  result = has_equality_method(classObj, methodName)
  or
  result = classObj.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Identifies which critical method is missing in a class
string get_missing_method(ClassValue classObj) {
  // Case 1: Missing equality methods
  not exists(has_equality_method(classObj, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing hash method (Python 2 specific)
  not classObj.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/** Indicates if a class is explicitly marked as unhashable */
predicate is_unhashable(ClassValue classObj) {
  classObj.lookup("__hash__") = Value::named("None")
  or
  classObj.lookup("__hash__").(CallableValue).neverReturns()
}

// Detects classes violating the hash contract by implementing only one of equality/hash
predicate has_hash_contract_violation(ClassValue classObj, string existingMethod, string missingMethod, CallableValue implementedMethod) {
  not is_unhashable(classObj) and
  missingMethod = get_missing_method(classObj) and
  implementedMethod = get_implemented_method(classObj, existingMethod) and
  not classObj.failedInference(_)
}

from ClassValue cls, string existingMethod, string missingMethod, CallableValue implementedMethod
where
  has_hash_contract_violation(cls, existingMethod, missingMethod, implementedMethod) and
  exists(cls.getScope()) // Filter results from source code
select implementedMethod, "Class $@ implements " + existingMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()