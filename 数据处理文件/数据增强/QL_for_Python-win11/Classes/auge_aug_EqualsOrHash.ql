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

// Helper predicate to check if a class defines equality comparison methods
CallableValue classDefinesEquality(ClassValue cls, string method) {
  // Check for __eq__ method in all Python versions
  method = "__eq__" and
  result = cls.declaredAttribute(method)
  or
  // Check for __cmp__ method in Python 2
  major_version() = 2 and
  method = "__cmp__" and
  result = cls.declaredAttribute(method)
}

// Helper predicate to check if a class implements a specific method
CallableValue classHasMethod(ClassValue cls, string method) {
  // Check equality methods
  result = classDefinesEquality(cls, method)
  or
  // Check __hash__ method
  method = "__hash__" and
  result = cls.declaredAttribute("__hash__")
}

// Determine which method is missing in a class
string getMissingMethod(ClassValue cls) {
  // Case 1: Missing equality methods
  not exists(classDefinesEquality(cls, _)) and
  (
    // Python 3 requires __eq__
    major_version() = 3 and
    result = "__eq__"
    or
    // Python 2 requires either __eq__ or __cmp__
    major_version() = 2 and
    result = "__eq__ or __cmp__"
  )
  or
  // Case 2: Missing __hash__ method (Python 2 only)
  major_version() = 2 and
  result = "__hash__" and
  not cls.declaresAttribute("__hash__")
}

/** Holds if this class is explicitly marked as unhashable */
predicate isExplicitlyUnhashable(ClassValue cls) {
  // Class explicitly sets __hash__ to None
  cls.lookup("__hash__") = Value::named("None")
  or
  // Class has __hash__ method that never returns
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

// Check if a class violates the hash contract by having one method but not the other
predicate violatesHashContract(ClassValue cls, string definedMethod, string missingMethod, CallableValue methodValue) {
  // Ensure class isn't explicitly unhashable
  not isExplicitlyUnhashable(cls) and
  // Identify the missing method
  missingMethod = getMissingMethod(cls) and
  // Get the existing method
  methodValue = classHasMethod(cls, definedMethod) and
  // Exclude classes with failed inference
  not cls.failedInference(_)
}

// Main query to identify classes violating hash contract
from ClassValue cls, string definedMethod, string missingMethod, CallableValue method
where
  violatesHashContract(cls, definedMethod, missingMethod, method) and
  exists(cls.getScope()) // Only include classes from source code
select method, "Class $@ implements " + definedMethod + " but does not define " + missingMethod + ".", cls,
  cls.getName()