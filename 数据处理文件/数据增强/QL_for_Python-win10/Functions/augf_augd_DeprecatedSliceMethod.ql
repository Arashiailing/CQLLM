/**
 * @name Deprecated slice method
 * @description Identifies usage of deprecated slicing special methods (__getslice__, __setslice__, __delslice__)
 *              which have been deprecated since Python 2.0. These methods should be replaced with
 *              __getitem__, __setitem__, and __delitem__ methods that accept slice objects.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to identify deprecated slice method names
predicate is_deprecated_slice_method(string deprecatedMethodName) {
  deprecatedMethodName = "__getslice__" or 
  deprecatedMethodName = "__setslice__" or 
  deprecatedMethodName = "__delslice__"
}

from PythonFunctionValue method, string deprecatedMethodName
where
  // Check if method name is deprecated and matches the function name
  method.getName() = deprecatedMethodName and
  is_deprecated_slice_method(deprecatedMethodName) and
  // Verify the function is a method and not an override
  method.getScope().isMethod() and
  not method.isOverridingMethod()
select method, deprecatedMethodName + " method has been deprecated since Python 2.0."