/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects methods where the signature differs from both its overridden methods 
 *              and the actual call arguments, which may lead to runtime errors when invoked.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // Python code analysis library for static analysis of Python code
import Expressions.CallArgs  // Library for handling call arguments in function invocations

from Call methodInvocation, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription
where
  // Exclude constructors to focus analysis on regular methods
  not baseMethod.getName() = "__init__" and
  // Verify that the derived class method actually overrides the base class method
  derivedMethod.overrides(baseMethod) and
  // Obtain the call node for the derived class method
  methodInvocation = derivedMethod.getAMethodCall().getNode() and
  // Validate that arguments are correct when called as a method
  correct_args_if_called_as_method(methodInvocation, derivedMethod) and
  (
    // Check for insufficient arguments scenario
    arg_count(methodInvocation) + 1 < baseMethod.minParameters() and 
    issueDescription = "too few arguments"
    or
    // Check for excessive arguments scenario
    arg_count(methodInvocation) >= baseMethod.maxParameters() and 
    issueDescription = "too many arguments"
    or
    // Check for mismatched keyword arguments scenario
    exists(string paramName |
      // Extract the keyword argument name from the method invocation
      methodInvocation.getAKeyword().getArg() = paramName and
      // Confirm the parameter name exists in the derived method's signature
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and
      // Verify the parameter name does not exist in the base method's signature
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and
      // Construct detailed issue description
      issueDescription = "an argument named '" + paramName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodInvocation, "call", derivedMethod,
  derivedMethod.descriptiveString()