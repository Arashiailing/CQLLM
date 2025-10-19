/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies methods where the signature differs from both its overridden methods 
 *              and the actual call arguments, potentially causing runtime errors during invocation.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // Python analysis module for static code analysis
import Expressions.CallArgs  // Module for handling function call argument analysis

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription
where
  // Exclude constructor methods, focusing on regular instance methods
  not baseMethod.getName() = "__init__" and
  // Verify that the derived method actually overrides the base method
  derivedMethod.overrides(baseMethod) and
  // Retrieve the call node where the derived method is invoked
  methodCall = derivedMethod.getAMethodCall().getNode() and
  // Validate argument correctness when called as a method
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  // Analyze different types of signature mismatches
  (
    // Case 1: Insufficient number of arguments
    (
      arg_count(methodCall) + 1 < baseMethod.minParameters() and 
      issueDescription = "too few arguments"
    )
    or
    // Case 2: Excessive number of arguments
    (
      arg_count(methodCall) >= baseMethod.maxParameters() and 
      issueDescription = "too many arguments"
    )
    or
    // Case 3: Mismatched keyword arguments
    (
      exists(string parameterName |
        // Extract keyword argument names from the method call
        methodCall.getAKeyword().getArg() = parameterName and
        // Confirm the parameter exists in the derived method's signature
        derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // Verify the parameter is missing from the base method's signature
        not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // Construct descriptive issue message
        issueDescription = "an argument named '" + parameterName + "'"
      )
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()