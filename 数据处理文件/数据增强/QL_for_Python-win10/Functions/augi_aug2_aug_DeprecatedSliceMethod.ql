/**
 * @name Deprecated slice method
 * @description Detects the use of deprecated slicing special methods that became obsolete starting from Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Query to find deprecated slice methods in Python codebases
// These methods were replaced with modern slicing syntax in Python 2.0
from PythonFunctionValue deprecatedFunc, string methodName
where
  // First verify the function is a class method that doesn't override a parent
  deprecatedFunc.getScope().isMethod() and
  not deprecatedFunc.isOverridingMethod() and
  // Then check if the function name matches any deprecated slice method
  deprecatedFunc.getName() = methodName and
  // Define the set of deprecated slice method names
  methodName in ["__getslice__", "__setslice__", "__delslice__"]
// Report findings with appropriate deprecation warning
select deprecatedFunc, methodName + " method has been deprecated since Python 2.0."