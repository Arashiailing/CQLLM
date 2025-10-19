/**
 * @name Inheritance method signature mismatch
 * @description Detects overriding methods with incompatible signatures compared to their parent methods,
 *              which may cause runtime errors during invocation.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python
import Expressions.CallArgs

// Identifies method signature conflicts in inheritance hierarchies
from Call invocationSite, FunctionValue childMethod, FunctionValue baseMethod, string errorDetail
where
  // Verify childMethod actually overrides baseMethod
  childMethod.overrides(baseMethod) and
  (
    // Case 1: Valid arguments for baseMethod but invalid for childMethod
    wrong_args(invocationSite, childMethod, _, errorDetail) and
    correct_args_if_called_as_method(invocationSite, baseMethod)
    or
    // Case 2: Presence of improperly named parameters
    exists(string paramName |
      illegally_named_parameter(invocationSite, childMethod, paramName) and
      errorDetail = "an argument named '" + paramName + "'" and
      // Verify baseMethod has parameter with same name
      baseMethod.getScope().getAnArg().(Name).getId() = paramName
    )
  )
select childMethod,
  "Overriding method signature incompatible with $@, where it receives " + errorDetail +
    ". Base method $@ has correct signature.", invocationSite, "here", baseMethod,
  baseMethod.descriptiveString()