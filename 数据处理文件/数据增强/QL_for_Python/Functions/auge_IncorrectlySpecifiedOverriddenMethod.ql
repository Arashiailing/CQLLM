/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects when a method overrides another with a different signature,
 *              and is called with arguments that match the overriding method but not the original.
 *              This creates a potential runtime error if the original method is called instead.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodInvocation, FunctionValue baseMethod, FunctionValue derivedMethod, string mismatchDetails
where
  // Skip constructor methods as they have special handling
  not baseMethod.getName() = "__init__" and
  // Verify inheritance relationship
  derivedMethod.overrides(baseMethod) and
  // Identify actual call site of the overriding method
  methodInvocation = derivedMethod.getAMethodCall().getNode() and
  // Confirm call arguments match the derived method's signature
  correct_args_if_called_as_method(methodInvocation, derivedMethod) and
  // Detect specific signature mismatches
  (
    // Case 1: Insufficient arguments for base method
    arg_count(methodInvocation) + 1 < baseMethod.minParameters() and 
    mismatchDetails = "too few arguments"
    or
    // Case 2: Excessive arguments for base method
    arg_count(methodInvocation) >= baseMethod.maxParameters() and 
    mismatchDetails = "too many arguments"
    or
    // Case 3: Keyword argument exists in derived but not in base method
    exists(string parameterName |
      methodInvocation.getAKeyword().getArg() = parameterName and
      derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and
      not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and
      mismatchDetails = "an argument named '" + parameterName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchDetails +
    ". Overriding method $@ matches the call.", methodInvocation, "call", derivedMethod,
  derivedMethod.descriptiveString()