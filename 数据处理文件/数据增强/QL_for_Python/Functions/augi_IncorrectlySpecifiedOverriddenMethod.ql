/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects when a method in a derived class has a signature that differs from both
 *              the base class method it overrides and the arguments with which it is called,
 *              potentially causing runtime errors if invoked.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription
where
  // Exclude constructor methods from analysis
  not baseMethod.getName() = "__init__" and
  // Establish inheritance relationship: derivedMethod overrides baseMethod
  derivedMethod.overrides(baseMethod) and
  // Get the actual call node where the derived method is invoked
  methodCall = derivedMethod.getAMethodCall().getNode() and
  // Verify that the call arguments are correct for the derived method
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  // Identify specific signature mismatch issues
  (
    // Case 1: Too few arguments provided in the call
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    issueDescription = "too few arguments"
    or
    // Case 2: Too many arguments provided in the call
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    issueDescription = "too many arguments"
    or
    // Case 3: Keyword argument exists in derived method but not in base method
    exists(string paramName |
      methodCall.getAKeyword().getArg() = paramName and  // Keyword argument in call
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and  // Parameter in derived method
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and  // Not in base method
      issueDescription = "an argument named '" + paramName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()