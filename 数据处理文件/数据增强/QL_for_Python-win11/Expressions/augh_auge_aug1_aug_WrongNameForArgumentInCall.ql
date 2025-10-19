/**
 * @name Wrong name for an argument in a call
 * @description Identifies function/method calls using keyword arguments that don't match
 *              any parameter names of the called function. Such mismatches cause runtime TypeErrors.
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

// Identify function calls with invalid keyword argument names
from Call callNode, FunctionObject calledFunction, string invalidKeyword
where
  // Verify the call uses an undefined keyword argument
  illegally_named_parameter_objectapi(callNode, calledFunction, invalidKeyword)
  and 
  // Exclude abstract methods as their parameters may be defined in implementations
  not calledFunction.isAbstract()
  and 
  // Exclude cases where the argument exists in overridden parent methods
  not exists(FunctionObject overriddenMethod |
    calledFunction.overrides(overriddenMethod) and
    overriddenMethod.getFunction().getAnArg().(Name).getId() = invalidKeyword
  )
// Report the invalid call with contextual information
select callNode, 
  "Keyword argument '" + invalidKeyword + "' is not a supported parameter name of $@.", 
  calledFunction, 
  calledFunction.descriptiveString()