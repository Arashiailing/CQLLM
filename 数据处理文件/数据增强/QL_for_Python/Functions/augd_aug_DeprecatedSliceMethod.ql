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

// Predicate: Check if the given method name is one of the deprecated slice methods
predicate is_deprecated_slice_method(string sliceMethodName) {
  // The method name must be one of the following deprecated slice methods
  sliceMethodName = "__getslice__" or sliceMethodName = "__setslice__" or sliceMethodName = "__delslice__"
}

// Query source: Filter Python function values to find deprecated slice methods
from PythonFunctionValue methodValue, string sliceMethodName
where
  // The function name matches the method name, which is a deprecated slice method
  methodValue.getName() = sliceMethodName and
  is_deprecated_slice_method(sliceMethodName) and
  // The function must be a class method and not overriding a parent class method
  methodValue.getScope().isMethod() and
  not methodValue.isOverridingMethod()
// Output: Display the function object and the corresponding deprecation warning
select methodValue, sliceMethodName + " method has been deprecated since Python 2.0."