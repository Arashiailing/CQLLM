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
from Call funcCall, FunctionObject calledFunction, string paramName
where
  // Verify the call contains an illegally named parameter
  illegally_named_parameter_objectapi(funcCall, calledFunction, paramName)
  and 
  // Exclude abstract methods from analysis
  not calledFunction.isAbstract()
  and 
  // Filter out cases where the parameter name exists in a parent overridden method
  not exists(FunctionObject parentFunction |
    calledFunction.overrides(parentFunction) and
    parentFunction.getFunction().getAnArg().(Name).getId() = paramName
  )
// Report the problematic call with appropriate error message
select funcCall, 
  "Keyword argument '" + paramName + "' is not a supported parameter name of $@.", 
  calledFunction, 
  calledFunction.descriptiveString()