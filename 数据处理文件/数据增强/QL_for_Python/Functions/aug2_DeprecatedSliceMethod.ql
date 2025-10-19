/**
 * @name Deprecated slice method
 * @description Identifies usage of deprecated slicing methods (__getslice__, __setslice__, __delslice__)
 *              which have been deprecated since Python 2.0. These methods should be avoided
 *              as they may be removed in future Python versions.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to determine if a method name is one of the deprecated slicing methods
predicate slice_method_name(string methodName) {
  // Check against the three deprecated slicing method names
  methodName = "__getslice__" or methodName = "__setslice__" or methodName = "__delslice__"
}

// Query to locate functions implementing deprecated slicing methods
from PythonFunctionValue func, string methodName
where
  // Verify that the function is a method within a class
  func.getScope().isMethod() and
  // Exclude methods that override parent class methods
  not func.isOverridingMethod() and
  // Confirm the method name is one of the deprecated slicing methods
  slice_method_name(methodName) and
  // Ensure the function's name matches the deprecated method name
  func.getName() = methodName
// Report the deprecated method with appropriate warning message
select func, methodName + " method has been deprecated since Python 2.0."