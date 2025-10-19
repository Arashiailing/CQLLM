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
CallableValue classDefinesEquality(ClassValue cls, string methodName) {
  // Standard equality check for all Python versions
  methodName = "__eq__" and
  result = cls.declaredAttribute(methodName)
  or
  // Legacy comparison method for Python 2
  major_version() = 2 and
  methodName = "__cmp__" and
  result = cls.declaredAttribute(methodName)
}

// Helper to check if a class implements a specific method
CallableValue classHasMethod(ClassValue cls, string methodName) {
  // Check equality methods via dedicated helper
  result = classDefinesEquality(cls, methodName)
  or
  // Check hash method implementation
  methodName = "__hash__" and
  result = cls.declaredAttribute("__hash__")
}

// Determine which required method is missing in a class
string missingMethod(ClassValue cls) {
  // Case 1: Missing equality methods
  not exists(classDefinesEquality(cls, _)) and
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
  not cls.declaresAttribute("__hash__")
}

/** Classes explicitly marked as unhashable */
predicate isUnhashable(ClassValue cls) {
  // Explicit __hash__ = None assignment
  cls.lookup("__hash__") = Value::named("None")
  or
  // __hash__ method that never returns
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Detect classes violating the hash contract
predicate violatesHashContract(ClassValue cls, string existingMethod, string absentMethod, Value method) {
  // Exclude explicitly unhashable classes
  not isUnhashable(cls) and
  // Identify the missing required method
  absentMethod = missingMethod(cls) and
  // Get the existing method implementation
  method = classHasMethod(cls, existingMethod) and
  // Exclude classes with analysis failures
  not cls.failedInference(_)
}

// Main query: Identify classes with hash contract violations
from ClassValue c, string existingMethod, string absentMethod, CallableValue method
where
  violatesHashContract(c, existingMethod, absentMethod, method) and
  exists(c.getScope()) // Ensure class is from source code
select method, "Class $@ implements " + existingMethod + " but does not define " + absentMethod + ".", c,
  c.getName()