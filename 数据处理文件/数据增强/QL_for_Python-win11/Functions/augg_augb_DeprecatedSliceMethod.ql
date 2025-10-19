/**
 * @name Deprecated slice method
 * @description Detects usage of deprecated slice methods (__getslice__, __setslice__, __delslice__)
 *              that have been obsolete since Python 2.0
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

from PythonFunctionValue func, string deprecatedMethodName
where
  // Verify function is a class method and not an override
  func.getScope().isMethod() and
  not func.isOverridingMethod() and
  // Check against deprecated slice method names
  (deprecatedMethodName = "__getslice__" or 
   deprecatedMethodName = "__setslice__" or 
   deprecatedMethodName = "__delslice__") and
  // Ensure function name matches deprecated method
  func.getName() = deprecatedMethodName
select func, deprecatedMethodName + " method has been deprecated since Python 2.0."