/**
 * @name Wrong name for an argument in a call
 * @description Identifies function/method calls using named arguments that don't 
 *              correspond to any declared parameter, leading to runtime TypeErrors.
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

// Find problematic function calls with mismatched named arguments
from Call callSite, FunctionObject calledFunction, string invalidArgName
where
  // Primary condition: argument name doesn't match any parameter of the target
  illegally_named_parameter_objectapi(callSite, calledFunction, invalidArgName) and
  // Skip abstract functions (may support dynamic parameters)
  not calledFunction.isAbstract() and
  // Exclude cases where parameter exists in overridden parent method
  not exists(FunctionObject parentMethod |
    calledFunction.overrides(parentMethod) and
    parentMethod.getFunction().getAnArg().(Name).getId() = invalidArgName
  )
select callSite, 
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  calledFunction, 
  calledFunction.descriptiveString()