/**
 * @name Deprecated slice method
 * @description Identifies deprecated slice methods (__getslice__, __setslice__, __delslice__)
 *              which became obsolete starting from Python 2.0
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

from PythonFunctionValue method, string obsoleteMethodName
where
  // Check if it's a method and not an override
  method.getScope().isMethod() and
  not method.isOverridingMethod() and
  // Check if method name matches any deprecated slice method
  method.getName() = obsoleteMethodName and
  obsoleteMethodName in ["__getslice__", "__setslice__", "__delslice__"]
select method, obsoleteMethodName + " method has been deprecated since Python 2.0."