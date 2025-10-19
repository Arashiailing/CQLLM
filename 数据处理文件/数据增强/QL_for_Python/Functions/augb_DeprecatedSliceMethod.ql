/**
 * @name Deprecated slice method
 * @description Identifies usage of deprecated slice methods (__getslice__, __setslice__, __delslice__)
 *              which have been obsolete since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to determine if a method name is one of the deprecated slice methods
predicate slice_method_name(string name) {
  name = "__getslice__" or name = "__setslice__" or name = "__delslice__"
}

// Query to find functions that implement deprecated slice methods
from PythonFunctionValue method, string methodName
where
  // Verify that the function is a method within a class
  method.getScope().isMethod() and
  // Exclude methods that are overrides (as they might be in base classes)
  not method.isOverridingMethod() and
  // Check if the method name matches one of the deprecated slice methods
  slice_method_name(methodName) and
  // Ensure the function's name matches the deprecated method name
  method.getName() = methodName
// Report the deprecated method with a warning message
select method, methodName + " method has been deprecated since Python 2.0."