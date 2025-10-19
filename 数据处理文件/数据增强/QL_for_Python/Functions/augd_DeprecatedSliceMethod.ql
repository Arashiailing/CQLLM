/**
 * @name Deprecated slice method
 * @description Defining special methods for slicing has been deprecated since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to identify deprecated slice method names
predicate is_deprecated_slice_method(string methodName) {
  methodName = "__getslice__" or 
  methodName = "__setslice__" or 
  methodName = "__delslice__"
}

from PythonFunctionValue func, string methodName
where
  // Verify the function is a method
  func.getScope().isMethod() and
  // Ensure it's not an override
  not func.isOverridingMethod() and
  // Check if method name is deprecated
  is_deprecated_slice_method(methodName) and
  // Match function name with deprecated method
  func.getName() = methodName
select func, methodName + " method has been deprecated since Python 2.0."