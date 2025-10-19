/**
 * @name Wrong name for an argument in a call
 * @description Detects function calls using named arguments that don't match
 *              any parameter of the target function, which will cause TypeError
 *              at runtime.
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

// Identify calls with incorrectly named arguments
from Call callSite, FunctionObject calledFunction, string wrongArgName
where
  // Check for invalid named argument usage
  illegally_named_parameter_objectapi(callSite, calledFunction, wrongArgName)
  and 
  // Exclude abstract methods from analysis
  not calledFunction.isAbstract()
  and 
  // Filter out cases where argument exists in overridden methods
  not exists(FunctionObject overriddenMethod |
    // Verify method inheritance relationship
    calledFunction.overrides(overriddenMethod)
    and 
    // Check if overridden method defines the argument
    overriddenMethod.getFunction().getAnArg().(Name).getId() = wrongArgName
  )
// Report findings with contextual information
select callSite, 
  "Keyword argument '" + wrongArgName + "' is not a supported parameter name of $@.", 
  calledFunction, 
  calledFunction.descriptiveString()