/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies situations where a derived class method overrides a base class method
 *              with a different signature. When the derived method is called with arguments
 *              matching its signature but not the base method's signature, a runtime error
 *              could occur if the base method is invoked instead.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python
import Expressions.CallArgs

from Call methodInvocation, FunctionValue baseMethod, FunctionValue derivedMethod, string signatureMismatchDetails
where
  // Filter out constructor methods as they require special handling
  not baseMethod.getName() = "__init__" and
  // Verify that the derived method overrides the base method
  derivedMethod.overrides(baseMethod) and
  // Identify the actual invocation point of the derived method
  methodInvocation = derivedMethod.getAMethodCall().getNode() and
  // Confirm that the call arguments match the derived method's signature
  correct_args_if_called_as_method(methodInvocation, derivedMethod) and
  // Detect specific signature mismatches between base and derived methods
  (
    // Case 1: Insufficient arguments for the base method
    arg_count(methodInvocation) + 1 < baseMethod.minParameters() and 
    signatureMismatchDetails = "too few arguments"
    or
    // Case 2: Excessive arguments for the base method
    arg_count(methodInvocation) >= baseMethod.maxParameters() and 
    signatureMismatchDetails = "too many arguments"
    or
    // Case 3: Keyword argument exists in derived method but not in base method
    exists(string argName |
      methodInvocation.getAKeyword().getArg() = argName and
      derivedMethod.getScope().getAnArg().(Name).getId() = argName and
      not baseMethod.getScope().getAnArg().(Name).getId() = argName and
      signatureMismatchDetails = "an argument named '" + argName + "'"
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + signatureMismatchDetails +
    ". Overriding method $@ matches the call.", methodInvocation, "call", derivedMethod,
  derivedMethod.descriptiveString()