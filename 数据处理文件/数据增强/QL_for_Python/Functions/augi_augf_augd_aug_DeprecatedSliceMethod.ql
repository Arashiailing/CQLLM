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

// Main query: Detects Python methods implementing deprecated slice special methods
from PythonFunctionValue deprecatedMethod, string methodName
where
  // Condition 1: Method name matches one of the deprecated slice special methods
  (methodName = "__getslice__" or 
   methodName = "__setslice__" or 
   methodName = "__delslice__") and
  deprecatedMethod.getName() = methodName and
  
  // Condition 2: Function must be defined as a method within a class context
  deprecatedMethod.getScope().isMethod() and
  
  // Condition 3: Method should not be overriding a parent class implementation
  not deprecatedMethod.isOverridingMethod()
// Result presentation: Display the method and its deprecation status
select deprecatedMethod, methodName + " method has been deprecated since Python 2.0."