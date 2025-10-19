/**
 * @name Inconsistent equality and hashing
 * @description Classes defining equality without hashability (or vice-versa) violate object model contracts
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
 * Determines if a class implements equality comparison methods
 * @param targetClass The class to check for equality methods
 * @param equalityMethodName The name of the equality method to look for
 * @returns The equality method if found in the class
 */
CallableValue implementsEqualityMethod(ClassValue targetClass, string equalityMethodName) {
  // Check for __eq__ in all versions or __cmp__ in Python 2
  (
    equalityMethodName = "__eq__"
    or
    major_version() = 2 and equalityMethodName = "__cmp__"
  ) and
  result = targetClass.declaredAttribute(equalityMethodName)
}

/**
 * Retrieves implemented methods for equality or hashing
 * @param targetClass The class to examine
 * @param methodName The name of the method to retrieve
 * @returns The method implementation if it exists
 */
CallableValue findImplementedMethod(ClassValue targetClass, string methodName) {
  // Get equality methods or __hash__ implementation
  result = implementsEqualityMethod(targetClass, methodName)
  or
  result = targetClass.declaredAttribute("__hash__") and methodName = "__hash__"
}

/**
 * Identifies missing methods in class implementation
 * @param targetClass The class to check for missing methods
 * @returns The name of the missing method
 */
string identifyMissingMethod(ClassValue targetClass) {
  // Detect missing equality methods based on Python version
  not exists(implementsEqualityMethod(targetClass, _)) and
  (
    result = "__eq__" and major_version() = 3
    or
    major_version() = 2 and result = "__eq__ or __cmp__"
  )
  or
  // Detect missing __hash__ in Python 2 (Python 3 handles this automatically)
  not targetClass.declaresAttribute(result) and result = "__hash__" and major_version() = 2
}

/**
 * Indicates when a class is explicitly unhashable
 * @param targetClass The class to check for unhashable status
 */
predicate isExplicitlyUnhashable(ClassValue targetClass) {
  // Check if __hash__ is set to None or never returns
  targetClass.lookup("__hash__") = Value::named("None")
  or
  targetClass.lookup("__hash__").(CallableValue).neverReturns()
}

/**
 * Detects violations of hash contract implementation
 * @param targetClass The class to check for contract violations
 * @param implementedMethod The name of the implemented method
 * @param missingMethod The name of the missing method
 * @param methodValue The method object that is implemented
 */
predicate breaksHashContract(ClassValue targetClass, string implementedMethod, string missingMethod, CallableValue methodValue) {
  // Exclude explicitly unhashable classes and failed inferences
  not isExplicitlyUnhashable(targetClass) and
  missingMethod = identifyMissingMethod(targetClass) and
  methodValue = findImplementedMethod(targetClass, implementedMethod) and
  not targetClass.failedInference(_)
}

// Main query: Find classes with inconsistent equality/hash implementations
from ClassValue targetClass, string implementedMethod, string missingMethod, CallableValue methodValue
where
  breaksHashContract(targetClass, implementedMethod, missingMethod, methodValue) and
  exists(targetClass.getScope()) // Filter out non-source classes
select methodValue, "Class $@ implements " + implementedMethod + " but does not define " + missingMethod + ".", targetClass,
  targetClass.getName()