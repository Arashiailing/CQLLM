/**
 * @name Deprecated slice method detection
 * @description This query identifies code that implements deprecated slicing methods
 *              (__getslice__, __setslice__, __delslice__) which were deprecated
 *              in Python 2.0. These methods should not be used as they may be
 *              removed in future Python versions.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

from PythonFunctionValue deprecatedMethod, string deprecatedMethodName
where
  // Check if the method name is one of the deprecated slicing methods
  (deprecatedMethodName = "__getslice__" or 
   deprecatedMethodName = "__setslice__" or 
   deprecatedMethodName = "__delslice__") and
  // Ensure the function's name matches the deprecated method name
  deprecatedMethod.getName() = deprecatedMethodName and
  // Verify that the function is a method within a class
  deprecatedMethod.getScope().isMethod() and
  // Exclude methods that override parent class methods to focus on direct implementations
  not deprecatedMethod.isOverridingMethod()
// Report the deprecated method with appropriate warning message
select deprecatedMethod, deprecatedMethodName + " method has been deprecated since Python 2.0."