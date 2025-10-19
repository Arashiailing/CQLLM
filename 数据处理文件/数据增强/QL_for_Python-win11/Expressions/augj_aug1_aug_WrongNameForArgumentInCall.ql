/**
 * @name Wrong name for an argument in a call
 * @description Detects function/method calls using keyword arguments that don't match
 *              any parameter names of the called function. Such mismatches lead to runtime TypeErrors.
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
from Call callSite, FunctionObject targetFunction, string invalidArgName
where
  // Verify the call uses an undefined keyword argument
  illegally_named_parameter_objectapi(callSite, targetFunction, invalidArgName)
  and 
  // Exclude abstract methods as their parameters may be defined in implementations
  not targetFunction.isAbstract()
  and 
  // Exclude cases where the argument exists in overridden parent methods
  not exists(FunctionObject parentFunc |
    targetFunction.overrides(parentFunc) and
    parentFunc.getFunction().getAnArg().(Name).getId() = invalidArgName
  )
// Report the invalid call with contextual information
select callSite, 
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()