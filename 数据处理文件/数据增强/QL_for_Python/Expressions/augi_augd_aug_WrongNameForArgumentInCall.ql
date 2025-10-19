/**
 * @name Mismatched Named Argument in Function Invocation
 * @description Detects function invocations that use named arguments which do not correspond
 *              to any parameter defined in the target function, leading to a runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-argument
 */

import python
import Expressions.CallArgs

// Locate function invocations containing invalid named parameters
from Call invocationSite, FunctionObject targetFunction, string argumentName
where
  // Confirm presence of mismatched named parameter in invocation
  illegally_named_parameter_objectapi(invocationSite, targetFunction, argumentName)
  and 
  // Exclude abstract methods from analysis scope
  not targetFunction.isAbstract()
  and 
  // Filter cases where parameter exists in overridden method implementations
  not exists(FunctionObject overriddenMethod |
    targetFunction.overrides(overriddenMethod) and
    overriddenMethod.getFunction().getAnArg().(Name).getId() = argumentName
  )
// Generate violation report with contextual details
select invocationSite, 
  "Keyword argument '" + argumentName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()