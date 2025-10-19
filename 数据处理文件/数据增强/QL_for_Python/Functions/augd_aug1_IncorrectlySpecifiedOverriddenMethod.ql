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

from Call invocation, FunctionValue parentMethod, FunctionValue childMethod, string problemDescription
where
  // Exclude constructors to focus on regular method analysis
  not parentMethod.getName() = "__init__" and
  // Verify that the child class method actually overrides the parent class method
  childMethod.overrides(parentMethod) and
  // Retrieve the call node for the child class method
  invocation = childMethod.getAMethodCall().getNode() and
  // Validate the correctness of arguments when called as a method
  correct_args_if_called_as_method(invocation, childMethod) and
  (
    // Check for insufficient arguments scenario
    arg_count(invocation) + 1 < parentMethod.minParameters() and problemDescription = "too few arguments"
    or
    // Check for excessive arguments scenario
    arg_count(invocation) >= parentMethod.maxParameters() and problemDescription = "too many arguments"
    or
    // Check for mismatched keyword arguments scenario
    exists(string argumentName |
      // Retrieve the keyword argument name from the invocation
      invocation.getAKeyword().getArg() = argumentName and
      // Confirm that the argument name exists in the child method's signature
      childMethod.getScope().getAnArg().(Name).getId() = argumentName and
      // Verify that the argument name does not exist in the parent method's signature
      not parentMethod.getScope().getAnArg().(Name).getId() = argumentName and
      // Construct the problem description
      problemDescription = "an argument named '" + argumentName + "'"
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", invocation, "call", childMethod,
  childMethod.descriptiveString()