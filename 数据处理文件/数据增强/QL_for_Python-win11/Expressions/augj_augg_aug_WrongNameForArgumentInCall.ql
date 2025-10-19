/**
 * @name Incorrect keyword argument name in function call
 * @description Identifies function calls that use a named argument which does not
 *              match any parameter of the target function, causing a TypeError at runtime.
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

// Identify function calls with incorrectly named keyword arguments
from Call invocation, FunctionObject targetFunction, string incorrectParamName
where
  // Check if the call contains an illegally named parameter
  illegally_named_parameter_objectapi(invocation, targetFunction, incorrectParamName)
  and 
  // Exclude abstract methods from analysis
  not targetFunction.isAbstract()
  and 
  // Filter out cases where the parameter name exists in a parent overridden method
  not exists(FunctionObject parentMethod |
    targetFunction.overrides(parentMethod) and
    parentMethod.getFunction().getAnArg().(Name).getId() = incorrectParamName
  )
// Report the problematic call with appropriate error message
select invocation, 
  "Keyword argument '" + incorrectParamName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()