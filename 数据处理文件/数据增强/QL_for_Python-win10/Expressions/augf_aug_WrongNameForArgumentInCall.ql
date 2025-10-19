/**
 * @name Incorrect named argument in function call
 * @description Identifies function calls using named arguments that don't match
 *              any parameter of the target function, which will cause runtime TypeError.
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
from Call call, FunctionObject callee, string argName
where
  // Verify the call contains an illegally named parameter
  illegally_named_parameter_objectapi(call, callee, argName)
  and 
  // Exclude abstract methods from analysis
  not callee.isAbstract()
  and 
  // Exclude cases where the argument exists in overridden methods
  not exists(FunctionObject overriddenFunc |
    // Check if the callee overrides another function
    callee.overrides(overriddenFunc)
    and 
    // Verify the overridden function contains the argument name
    overriddenFunc.getFunction().getAnArg().(Name).getId() = argName
  )
// Report the problematic call with contextual information
select call, 
  "Keyword argument '" + argName + "' is not a supported parameter name of $@.", 
  callee, 
  callee.descriptiveString()