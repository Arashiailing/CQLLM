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

from Call methodCallSite, FunctionValue overriddenMethod, FunctionValue overridingMethod, string mismatchInfo
where
  // Exclude constructor methods as they require special handling
  not overriddenMethod.getName() = "__init__" and
  // Ensure inheritance relationship exists
  overridingMethod.overrides(overriddenMethod) and
  // Locate the actual call site of the overriding method
  methodCallSite = overridingMethod.getAMethodCall().getNode() and
  // Validate that call arguments align with the overriding method's signature
  correct_args_if_called_as_method(methodCallSite, overridingMethod) and
  // Check for specific signature mismatches
  (
    // Scenario 1: Inadequate arguments for the overridden method
    arg_count(methodCallSite) + 1 < overriddenMethod.minParameters() and 
    mismatchInfo = "too few arguments"
    or
    // Scenario 2: Excessive arguments for the overridden method
    arg_count(methodCallSite) >= overriddenMethod.maxParameters() and 
    mismatchInfo = "too many arguments"
    or
    // Scenario 3: Keyword argument present in overriding but absent in overridden method
    exists(string parameterName |
      methodCallSite.getAKeyword().getArg() = parameterName and
      overridingMethod.getScope().getAnArg().(Name).getId() = parameterName and
      not overriddenMethod.getScope().getAnArg().(Name).getId() = parameterName and
      mismatchInfo = "an argument named '" + parameterName + "'"
    )
  )
select overriddenMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchInfo +
    ". Overriding method $@ matches the call.", methodCallSite, "call", overridingMethod,
  overridingMethod.descriptiveString()