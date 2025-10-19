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

from Call invocation, FunctionObject targetFunction, string paramName
where
  // Identify calls with illegally named parameters
  illegally_named_parameter_objectapi(invocation, targetFunction, paramName)
  // Exclude abstract functions from analysis
  and not targetFunction.isAbstract()
  // Ensure no overridden method contains the parameter name
  and not exists(FunctionObject overriddenFunction |
    targetFunction.overrides(overriddenFunction) and
    overriddenFunction.getFunction().getAnArg().(Name).getId() = paramName
  )
select invocation, 
  "Keyword argument '" + paramName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()