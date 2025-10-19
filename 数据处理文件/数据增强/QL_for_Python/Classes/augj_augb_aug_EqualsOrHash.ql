/**
 * @name Inconsistent equality and hashing
 * @description Identifies classes violating object model contracts by implementing equality without hashability (or vice-versa)
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

// Helper to verify equality method implementation in a class
CallableValue classDefinesEquality(ClassValue klass, string methodName) {
  // Standard equality check for all Python versions
  methodName = "__eq__" and
  result = klass.declaredAttribute(methodName)
  or
  // Legacy comparison method for Python 2 compatibility
  major_version() = 2 and
  methodName = "__cmp__" and
  result = klass.declaredAttribute(methodName)
}

// Helper to verify specific method implementation in a class
CallableValue classHasMethod(ClassValue klass, string methodName) {
  // Check equality methods through dedicated helper
  result = classDefinesEquality(klass, methodName)
  or
  // Check hash method implementation
  methodName = "__hash__" and
  result = klass.declaredAttribute("__hash__")
}

// Determine the missing required method in a class
string missingMethod(ClassValue klass) {
  // Case 1: Missing equality methods
  not exists(classDefinesEquality(klass, _)) and
  (
    // Python 3 requires __eq__
    major_version() = 3 and
    result = "__eq__"
    or
    // Python 2 accepts either __eq__ or __cmp__
    major_version() = 2 and
    result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 only)
  major_version() = 2 and
  result = "__hash__" and
  not klass.declaresAttribute("__hash__")
}

/** Classes explicitly marked as unhashable */
predicate isUnhashable(ClassValue klass) {
  // Explicit __hash__ = None assignment
  klass.lookup("__hash__") = Value::named("None")
  or
  // __hash__ method that never returns
  klass.lookup("__hash__").(CallableValue).neverReturns()
}

// Identify classes violating the hash contract
predicate violatesHashContract(ClassValue klass, string existingMethodName, string absentMethodName, Value methodImpl) {
  // Exclude explicitly unhashable classes
  not isUnhashable(klass) and
  // Identify the missing required method
  absentMethodName = missingMethod(klass) and
  // Get the existing method implementation
  methodImpl = classHasMethod(klass, existingMethodName) and
  // Exclude classes with analysis failures
  not klass.failedInference(_)
}

// Main query: Identify classes with hash contract violations
from ClassValue klass, string existingMethodName, string absentMethodName, CallableValue methodImpl
where
  violatesHashContract(klass, existingMethodName, absentMethodName, methodImpl) and
  exists(klass.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethodName + " but does not define " + absentMethodName + ".", klass,
  klass.getName()