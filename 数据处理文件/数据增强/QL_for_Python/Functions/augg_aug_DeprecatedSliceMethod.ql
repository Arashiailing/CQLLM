/**
 * @name Deprecated slice method usage
 * @description Detects deprecated slice special methods that have been obsolete since Python 2.0.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate: Determines if a method name is one of the deprecated slice methods
predicate is_deprecated_slice_method(string sliceMethodName) {
  sliceMethodName = ["__getslice__", "__setslice__", "__delslice__"]
}

// Source: Identifies target methods from Python function values
from PythonFunctionValue methodVal, string sliceMethodName
where
  // Condition 1: The method name matches and is a deprecated slice method
  methodVal.getName() = sliceMethodName and
  is_deprecated_slice_method(sliceMethodName) and
  // Condition 2: The function must be a class method
  methodVal.getScope().isMethod() and
  // Condition 3: The function must not override a parent class method
  not methodVal.isOverridingMethod()
// Output: Displays the method object and corresponding deprecation warning
select methodVal, sliceMethodName + " method has been deprecated since Python 2.0."