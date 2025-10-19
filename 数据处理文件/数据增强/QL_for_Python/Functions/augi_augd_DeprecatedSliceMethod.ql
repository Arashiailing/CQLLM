/**
 * @name Obsolete slice method implementation
 * @description Implementation of special slice methods (__getslice__, __setslice__, __delslice__) 
 *              is considered obsolete since Python 2.0 release.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/deprecated-slice-method
 */

import python

// Predicate to identify deprecated slice method names
predicate is_deprecated_slice_method(string sliceMethodName) {
  sliceMethodName = "__getslice__" or 
  sliceMethodName = "__setslice__" or 
  sliceMethodName = "__delslice__"
}

from PythonFunctionValue sliceMethod
where
  // Verify the function is a method and not an override
  sliceMethod.getScope().isMethod() and
  not sliceMethod.isOverridingMethod() and
  // Check if method name is deprecated
  is_deprecated_slice_method(sliceMethod.getName())
select sliceMethod, sliceMethod.getName() + " method has been deprecated since Python 2.0."