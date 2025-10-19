/**
 * @name Wrong name for an argument in a call
 * @description Detects calls using named arguments that don't match any parameter
 *              of the target function/method, causing runtime TypeErrors.
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

// Identify function calls with invalid named arguments
from Call invocation, FunctionObject targetFunc, string paramName
where
  // Core check: argument name doesn't match any parameter
  illegally_named_parameter_objectapi(invocation, targetFunc, paramName) and
  // Exclude abstract functions (may have dynamic parameters)
  not targetFunc.isAbstract() and
  // Exclude cases where parent class defines the parameter
  not exists(FunctionObject overriddenMethod |
    targetFunc.overrides(overriddenMethod) and
    overriddenMethod.getFunction().getAnArg().(Name).getId() = paramName
  )
select invocation, 
  "Keyword argument '" + paramName + "' is not a supported parameter name of $@.", 
  targetFunc, 
  targetFunc.descriptiveString()