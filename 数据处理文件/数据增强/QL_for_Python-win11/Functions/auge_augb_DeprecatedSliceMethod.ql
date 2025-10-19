/**
 * @name Deprecated slice method
 * @description Identifies usage of obsolete slice methods (__getslice__, __setslice__, __delslice__)
 *              that have been deprecated since Python 2.0 and should be replaced with modern slicing syntax.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Helper predicate to check if a method name is one of the deprecated slice operations
predicate slice_method_name(string methodName) {
  methodName = "__getslice__" or methodName = "__setslice__" or methodName = "__delslice__"
}

// Main query to locate functions implementing deprecated slice methods
from PythonFunctionValue targetMethod, string methodName
where
  // Verify the function is a class method (not a standalone function)
  targetMethod.getScope().isMethod() and
  // Exclude methods that are overrides from parent classes
  not targetMethod.isOverridingMethod() and
  // Confirm the method name matches one of our deprecated slice methods
  targetMethod.getName() = methodName and
  // Validate the method name is in our list of deprecated slice methods
  slice_method_name(methodName)
// Generate alert with the deprecated method and explanatory message
select targetMethod, methodName + " method has been deprecated since Python 2.0."