/**
 * @name Deprecated slice method
 * @description Identifies usage of outdated slicing special methods that were deprecated in Python 2.0
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Helper predicate: Determines if a method name belongs to the deprecated slice methods collection
predicate is_deprecated_slice_method(string deprecatedMethodName) {
  // Check if the method name matches any of the deprecated slice special methods
  deprecatedMethodName = "__getslice__" or 
  deprecatedMethodName = "__setslice__" or 
  deprecatedMethodName = "__delslice__"
}

// Main query: Locate Python functions that implement deprecated slice methods
from PythonFunctionValue funcValue, string deprecatedMethodName
where
  // Condition 1: Function name corresponds to a deprecated slice method
  funcValue.getName() = deprecatedMethodName and
  is_deprecated_slice_method(deprecatedMethodName) and
  
  // Condition 2: Function must be defined as a method within a class
  funcValue.getScope().isMethod() and
  
  // Condition 3: Method should not be overriding a parent class implementation
  not funcValue.isOverridingMethod()
// Result presentation: Show the function and its deprecation status message
select funcValue, deprecatedMethodName + " method has been deprecated since Python 2.0."