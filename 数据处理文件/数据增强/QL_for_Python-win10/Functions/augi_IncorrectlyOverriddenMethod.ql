/**
 * @name Mismatch between signature and use of an overriding method
 * @description Detects overriding methods with signatures that differ from their base methods,
 *              which would likely cause errors when called.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python
import Expressions.CallArgs

// Identify methods with signature mismatches in inheritance hierarchies
from Call invocation, FunctionValue overridingMethod, FunctionValue baseMethod, string issueDescription
where
  overridingMethod.overrides(baseMethod) and
  (
    // Case 1: Argument count/type mismatch between method call and base method
    wrong_args(invocation, overridingMethod, _, issueDescription) and
    correct_args_if_called_as_method(invocation, baseMethod)
    or
    // Case 2: Illegal parameter name collision with base method
    exists(string paramName |
      illegally_named_parameter(invocation, overridingMethod, paramName) and
      issueDescription = "an argument named '" + paramName + "'" and
      baseMethod.getScope().getAnArg().(Name).getId() = paramName
    )
  )
select overridingMethod,
  "Overriding method signature does not match $@, where it is passed " + issueDescription +
    ". Overridden method $@ is correctly specified.", 
  invocation, "here", baseMethod, baseMethod.descriptiveString()