/**
 * @name Inconsistent equality and hashing
 * @description Detects classes violating object model contracts by implementing equality without hashability (or vice-versa)
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

// Helper to check if class implements equality comparison methods
CallableValue getEqualityMethod(ClassValue classObj, string methodName) {
  (
    methodName = "__eq__"
    or
    major_version() = 2 and methodName = "__cmp__"
  ) and
  result = classObj.declaredAttribute(methodName)
}

// Unified method existence checker for equality/hashing methods
CallableValue getImplementedMethod(ClassValue classObj, string methodName) {
  result = getEqualityMethod(classObj, methodName)
  or
  result = classObj.declaredAttribute("__hash__") and methodName = "__hash__"
}

// Determine which method is missing in class implementation
string getMissingMethodName(ClassValue classObj) {
  // Case 1: Missing equality methods
  not exists(getEqualityMethod(classObj, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing hash method (Python 2 specific)
  not classObj.declaresAttribute(result) and 
  result = "__hash__" and 
  major_version() = 2
}

/** Check if class is explicitly marked as unhashable */
predicate isExplicitlyUnhashable(ClassValue classObj) {
  classObj.lookup("__hash__") = Value::named("None")
  or
  classObj.lookup("__hash__").(CallableValue).neverReturns()
}

// Core violation detection logic
predicate hasHashContractViolation(ClassValue classObj, string existingMethod, string absentMethod, Value method) {
  not isExplicitlyUnhashable(classObj) and
  absentMethod = getMissingMethodName(classObj) and
  method = getImplementedMethod(classObj, existingMethod) and
  not classObj.failedInference(_)
}

// Main query selecting violating classes with diagnostic context
from ClassValue classObj, string existingMethod, string absentMethod, CallableValue method
where
  hasHashContractViolation(classObj, existingMethod, absentMethod, method) and
  exists(classObj.getScope()) // Ensure source code origin
select method, "Class $@ implements " + existingMethod + " but lacks " + absentMethod + " definition.", classObj,
  classObj.getName()