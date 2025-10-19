/**
 * @name Deprecated slice method
 * @description Identifies usage of deprecated slicing special methods which have been obsolete since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

/**
 * Predicate to determine if a method name is one of the deprecated slice methods.
 * These methods were made obsolete starting from Python 2.0.
 */
predicate isDeprecatedSliceMethod(string deprecatedMethodName) {
  deprecatedMethodName in ["__getslice__", "__setslice__", "__delslice__"]
}

// Main query to identify deprecated slice methods in Python code
from PythonFunctionValue targetMethod, string deprecatedMethodName
where
  // Check if the method name is one of the deprecated slice methods
  targetMethod.getName() = deprecatedMethodName and
  isDeprecatedSliceMethod(deprecatedMethodName) and
  // Ensure the method is defined within a class context
  targetMethod.getScope().isMethod() and
  // Exclude methods that override parent class implementations
  not targetMethod.isOverridingMethod()
// Output the deprecated method with appropriate warning message
select targetMethod, deprecatedMethodName + " method has been deprecated since Python 2.0."