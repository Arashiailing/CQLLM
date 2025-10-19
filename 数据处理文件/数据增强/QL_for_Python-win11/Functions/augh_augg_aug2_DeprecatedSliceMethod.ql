/**
 * @name Detection of deprecated slice methods
 * @description Identifies implementations of deprecated slicing methods
 *              (__getslice__, __setslice__, __delslice__) that were marked
 *              as obsolete in Python 2.0. These methods are candidates for
 *              removal in future Python versions and should be avoided.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

from PythonFunctionValue obsoleteSliceFunc, string obsoleteMethodName
where
  // Define the set of deprecated slice method names
  (obsoleteMethodName = "__getslice__" or 
   obsoleteMethodName = "__setslice__" or 
   obsoleteMethodName = "__delslice__") and
  // Verify function characteristics
  obsoleteSliceFunc.getName() = obsoleteMethodName and
  obsoleteSliceFunc.getScope().isMethod() and
  not obsoleteSliceFunc.isOverridingMethod()
// Report the deprecated method with a warning message
select obsoleteSliceFunc, obsoleteMethodName + " method has been deprecated since Python 2.0."