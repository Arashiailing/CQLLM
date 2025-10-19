/**
 * @name Inconsistent equality and hashing
 * @description Detects classes that define equality without defining hashability (or vice-versa),
 *              which violates the object model and can lead to unexpected behavior.
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

/**
 * Helper function to check if a class defines equality comparison methods.
 * In Python 3, only __eq__ is checked. In Python 2, both __eq__ and __cmp__ are considered.
 */
CallableValue classDefinesEquality(ClassValue cls, string methodName) {
  // Check for __eq__ method in all Python versions
  methodName = "__eq__" and
  result = cls.declaredAttribute(methodName)
  or
  // Check for __cmp__ method in Python 2
  major_version() = 2 and
  methodName = "__cmp__" and
  result = cls.declaredAttribute(methodName)
}

/**
 * Helper function to check if a class implements a specific method.
 * This includes both equality methods (__eq__, __cmp__) and the __hash__ method.
 */
CallableValue classHasMethod(ClassValue cls, string methodName) {
  // Check equality methods
  result = classDefinesEquality(cls, methodName)
  or
  // Check __hash__ method
  methodName = "__hash__" and
  result = cls.declaredAttribute("__hash__")
}

/**
 * Determines which method is missing in a class to satisfy the hash contract.
 * In Python 3, __eq__ is required. In Python 2, either __eq__ or __cmp__ is required.
 * The __hash__ method is required in both versions if the class is hashable.
 */
string missingMethod(ClassValue cls) {
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

/**
 * Determines if a class is explicitly marked as unhashable.
 * This happens when __hash__ is set to None or when __hash__ never returns.
 */
predicate isUnhashable(ClassValue cls) {
  // Class explicitly sets __hash__ to None
  cls.lookup("__hash__") = Value::named("None")
  or
  // Class has __hash__ method that never returns
  cls.lookup("__hash__").(CallableValue).neverReturns()
}

/**
 * Checks if a class violates the hash contract by not implementing
 * required methods while not being explicitly unhashable.
 */
predicate violatesHashContract(ClassValue cls, string implementedMethod, string missingMethodName, Value methodImpl) {
  // Ensure class isn't explicitly unhashable
  not isUnhashable(cls) and
  // Identify the missing method
  missingMethodName = missingMethod(cls) and
  // Get the existing method
  methodImpl = classHasMethod(cls, implementedMethod) and
  // Exclude classes with failed inference
  not cls.failedInference(_)
}

// Main query to identify classes violating hash contract
from ClassValue problemClass, string implementedMethod, string missingMethodName, CallableValue method
where
  violatesHashContract(problemClass, implementedMethod, missingMethodName, method) and
  exists(problemClass.getScope()) // Only include classes from source code
select method, "Class $@ implements " + implementedMethod + " but does not define " + missingMethodName + ".", problemClass,
  problemClass.getName()