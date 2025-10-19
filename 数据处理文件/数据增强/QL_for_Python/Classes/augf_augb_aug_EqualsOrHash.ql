/**
 * @name Inconsistent equality and hashing
 * @description Detects classes violating object model by defining equality without hashability (or vice-versa)
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

// Helper to check if a class implements equality comparison methods
CallableValue classDefinesEquality(ClassValue targetClass, string equalityMethodName) {
  // Standard equality check for all Python versions
  equalityMethodName = "__eq__" and
  result = targetClass.declaredAttribute(equalityMethodName)
  or
  // Legacy comparison method for Python 2
  major_version() = 2 and
  equalityMethodName = "__cmp__" and
  result = targetClass.declaredAttribute(equalityMethodName)
}

// Helper to check if a class implements a specific method
CallableValue classHasMethod(ClassValue targetClass, string methodName) {
  // Check equality methods via dedicated helper
  result = classDefinesEquality(targetClass, methodName)
  or
  // Check hash method implementation
  methodName = "__hash__" and
  result = targetClass.declaredAttribute("__hash__")
}

// Determine which required method is missing in a class
string missingMethod(ClassValue targetClass) {
  // Case 1: Missing equality methods
  not exists(classDefinesEquality(targetClass, _)) and
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
  not targetClass.declaresAttribute("__hash__")
}

/** Classes explicitly marked as unhashable */
predicate isUnhashable(ClassValue targetClass) {
  // Explicit __hash__ = None assignment
  targetClass.lookup("__hash__") = Value::named("None")
  or
  // __hash__ method that never returns
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect classes violating the hash contract
predicate violatesHashContract(ClassValue targetClass, string existingMethodName, string absentMethodName, Value methodImpl) {
  // Exclude explicitly unhashable classes
  not isUnhashable(targetClass) and
  // Identify the missing required method
  absentMethodName = missingMethod(targetClass) and
  // Get the existing method implementation
  methodImpl = classHasMethod(targetClass, existingMethodName) and
  // Exclude classes with analysis failures
  not targetClass.failedInference(_)
}

// Main query: Identify classes with hash contract violations
from ClassValue targetClass, string existingMethodName, string absentMethodName, CallableValue methodImpl
where
  violatesHashContract(targetClass, existingMethodName, absentMethodName, methodImpl) and
  exists(targetClass.getScope()) // Ensure class is from source code
select methodImpl, "Class $@ implements " + existingMethodName + " but does not define " + absentMethodName + ".", targetClass,
  targetClass.getName()