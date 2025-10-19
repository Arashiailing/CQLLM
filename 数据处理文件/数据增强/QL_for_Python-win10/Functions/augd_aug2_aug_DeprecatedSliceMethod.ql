/**
 * @name Deprecated slice method
 * @description Identifies deprecated slice special methods (__getslice__, __setslice__, __delslice__) 
 *              that have been obsolete since Python 2.0. These methods should be replaced with 
 *              modern slicing syntax using __getitem__, __setitem__, and __delitem__.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Query to detect deprecated slice methods in Python code
from PythonFunctionValue deprecatedFunc, string deprecatedSliceMethod
where
  // Identify deprecated slice method names
  exists(string methodName |
    methodName = "__getslice__" or 
    methodName = "__setslice__" or 
    methodName = "__delslice__"
  |
    deprecatedSliceMethod = methodName and
    // Match function name to deprecated method
    deprecatedFunc.getName() = deprecatedSliceMethod
  ) and
  // Verify function is a class method (not standalone)
  deprecatedFunc.getScope().isMethod() and
  // Exclude methods overriding parent implementations
  not deprecatedFunc.isOverridingMethod()
// Output deprecated function with deprecation warning
select deprecatedFunc, deprecatedSliceMethod + " method has been deprecated since Python 2.0."