/**
 * @name Method signature mismatch in inheritance
 * @description Identifies methods that override a parent method but with incompatible signatures,
 *              potentially leading to runtime errors when invoked.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python
import Expressions.CallArgs

// Detects methods with signature mismatches in inheritance hierarchies
from Call methodInvocation, FunctionValue derivedMethod, FunctionValue parentMethod, string problemDescription
where
  // Verify that derivedMethod actually overrides parentMethod
  derivedMethod.overrides(parentMethod) and
  (
    // Case 1: Incorrect arguments when calling derivedMethod, but correct for parentMethod
    wrong_args(methodInvocation, derivedMethod, _, problemDescription) and
    correct_args_if_called_as_method(methodInvocation, parentMethod)
    or
    // Case 2: Presence of illegally named parameters
    exists(string parameterName |
      illegally_named_parameter(methodInvocation, derivedMethod, parameterName) and
      problemDescription = "an argument named '" + parameterName + "'" and
      // Check if parentMethod has a parameter with the same name
      parentMethod.getScope().getAnArg().(Name).getId() = parameterName
    )
  )
select derivedMethod,
  "Overriding method signature does not match $@, where it is passed " + problemDescription +
    ". Overridden method $@ is correctly specified.", methodInvocation, "here", parentMethod,
  parentMethod.descriptiveString()