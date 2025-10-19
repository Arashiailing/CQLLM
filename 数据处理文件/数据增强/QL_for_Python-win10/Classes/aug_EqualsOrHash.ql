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

// Helper function to check if a class defines equality comparison methods
CallableValue classDefinesEquality(ClassValue targetClass, string methodName) {
  // Check for __eq__ method in all Python versions
  methodName = "__eq__" and
  result = targetClass.declaredAttribute(methodName)
  or
  // Check for __cmp__ method in Python 2
  major_version() = 2 and
  methodName = "__cmp__" and
  result = targetClass.declaredAttribute(methodName)
}

// Helper function to check if a class implements a specific method
CallableValue classHasMethod(ClassValue targetClass, string methodName) {
  // Check equality methods
  result = classDefinesEquality(targetClass, methodName)
  or
  // Check __hash__ method
  methodName = "__hash__" and
  result = targetClass.declaredAttribute("__hash__")
}

// Determine which method is missing in a class
string missingMethod(ClassValue targetClass) {
  // Case 1: Missing equality methods
  not exists(classDefinesEquality(targetClass, _)) and
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
  not targetClass.declaresAttribute("__hash__")
}

/** Holds if this class is unhashable */
predicate isUnhashable(ClassValue targetClass) {
  // Class explicitly sets __hash__ to None
  targetClass.lookup("__hash__") = Value::named("None")
  or
  // Class has __hash__ method that never returns
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

// Check if a class violates the hash contract
predicate violatesHashContract(ClassValue targetClass, string existingMethod, string absentMethod, Value methodValue) {
  // Ensure class isn't explicitly unhashable
  not isUnhashable(targetClass) and
  // Identify the missing method
  absentMethod = missingMethod(targetClass) and
  // Get the existing method
  methodValue = classHasMethod(targetClass, existingMethod) and
  // Exclude classes with failed inference
  not targetClass.failedInference(_)
}

// Main query to identify classes violating hash contract
from ClassValue c, string existingMethod, string absentMethod, CallableValue method
where
  violatesHashContract(c, existingMethod, absentMethod, method) and
  exists(c.getScope()) // Only include classes from source code
select method, "Class $@ implements " + existingMethod + " but does not define " + absentMethod + ".", c,
  c.getName()