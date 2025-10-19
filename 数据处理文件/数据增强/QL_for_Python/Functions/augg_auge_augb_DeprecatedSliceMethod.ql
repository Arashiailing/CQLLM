/**
 * @name Deprecated slice method
 * @description Detects usage of obsolete slice methods (__getslice__, __setslice__, __delslice__)
 *              deprecated since Python 2.0. Replace with modern slicing syntax.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

from PythonFunctionValue deprecatedMethod, string deprecatedName
where
  // Ensure the function is a class method (not standalone)
  deprecatedMethod.getScope().isMethod() and
  // Exclude overrides from parent classes
  not deprecatedMethod.isOverridingMethod() and
  // Match deprecated slice method names
  deprecatedMethod.getName() = deprecatedName and
  // Validate against known deprecated slice methods
  deprecatedName in ["__getslice__", "__setslice__", "__delslice__"]
// Generate alert with method and deprecation message
select deprecatedMethod, deprecatedName + " method has been deprecated since Python 2.0."