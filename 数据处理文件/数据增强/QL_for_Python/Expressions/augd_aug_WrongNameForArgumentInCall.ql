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
from Call callSite, FunctionObject callee, string paramName
where
  // Verify presence of illegally named parameter in call
  illegally_named_parameter_objectapi(callSite, callee, paramName)
  and 
  // Exclude abstract methods from analysis
  not callee.isAbstract()
  and 
  // Filter out cases where parameter exists in overridden method
  not exists(FunctionObject overriddenMethod |
    callee.overrides(overriddenMethod) and
    overriddenMethod.getFunction().getAnArg().(Name).getId() = paramName
  )
// Report violation with contextual information
select callSite, 
  "Keyword argument '" + paramName + "' is not a supported parameter name of $@.", 
  callee, 
  callee.descriptiveString()