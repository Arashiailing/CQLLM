/**
 * @name Deprecated slice method
 * @description Detects the use of obsolete slice special methods (__getslice__, __setslice__, __delslice__) 
 *              which are no longer recommended since Python 2.0. These should be replaced with 
 *              contemporary slicing syntax via __getitem__, __setitem__, and __delitem__.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Query to identify deprecated slice methods in Python code
from PythonFunctionValue obsoleteMethod, string methodName
where
  // Check if the method name is one of the deprecated slice methods
  methodName = obsoleteMethod.getName() and
  methodName in ["__getslice__", "__setslice__", "__delslice__"] and
  // Verify function is a class method (not standalone)
  obsoleteMethod.getScope().isMethod() and
  // Exclude methods overriding parent implementations
  not obsoleteMethod.isOverridingMethod()
// Report the deprecated method with an appropriate warning message
select obsoleteMethod, methodName + " method has been deprecated since Python 2.0."