/**
 * @name Deprecated slice method
 * @description Detects the use of obsolete slicing special methods that were deprecated in Python 2.0.
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
  // Check if the method name matches any deprecated slice special methods
  methodName = "__getslice__" or 
  methodName = "__setslice__" or 
  methodName = "__delslice__"
}

// Query to find deprecated slice methods in Python code
from PythonFunctionValue functionObj, string methodName
where
  // Ensure the function name matches a deprecated slice method
  functionObj.getName() = methodName and
  is_deprecated_slice_method(methodName) and
  // Verify the function is a class method and not overriding parent methods
  functionObj.getScope().isMethod() and
  not functionObj.isOverridingMethod()
// Output deprecation warning with method name
select functionObj, methodName + " method has been deprecated since Python 2.0."