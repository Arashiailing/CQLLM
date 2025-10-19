/**
 * @name Deprecated slice method
 * @description Detects the use of deprecated slicing methods (__getslice__, __setslice__, __delslice__)
 *              in Python code. These methods were deprecated in Python 2.0 and should be replaced
 *              with modern slicing syntax to ensure future compatibility.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to determine if a method name is one of the deprecated slicing methods
predicate slice_method_name(string deprecatedMethodName) {
  // Check against the three deprecated slicing method names
  deprecatedMethodName = "__getslice__" or 
  deprecatedMethodName = "__setslice__" or 
  deprecatedMethodName = "__delslice__"
}

// Query to locate functions implementing deprecated slicing methods
from PythonFunctionValue deprecatedMethod, string deprecatedMethodName
where
  // Conditions to identify deprecated slice methods
  deprecatedMethod.getScope().isMethod() and          // Must be a method within a class
  not deprecatedMethod.isOverridingMethod() and       // Should not override parent class methods
  slice_method_name(deprecatedMethodName) and         // Must be one of the deprecated method names
  deprecatedMethod.getName() = deprecatedMethodName   // Function name must match the deprecated method name
// Report the deprecated method with appropriate warning message
select deprecatedMethod, deprecatedMethodName + " method has been deprecated since Python 2.0."