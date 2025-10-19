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

// Main query: Identify deprecated slice methods in Python code
from PythonFunctionValue functionVal, string sliceMethodName
where
  // Check if the method name matches any of the deprecated slice methods
  (sliceMethodName = "__getslice__" or 
   sliceMethodName = "__setslice__" or 
   sliceMethodName = "__delslice__") and
  // Ensure the function name corresponds to the identified deprecated method
  functionVal.getName() = sliceMethodName and
  // Verify the function is defined as a class method
  functionVal.getScope().isMethod() and
  // Exclude methods that override parent class implementations
  not functionVal.isOverridingMethod()
// Output the function object with a deprecation warning message
select functionVal, sliceMethodName + " method has been deprecated since Python 2.0."