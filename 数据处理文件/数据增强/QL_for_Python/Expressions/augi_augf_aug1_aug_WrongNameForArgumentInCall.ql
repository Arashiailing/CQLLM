/**
 * @name Wrong name for an argument in a call
 * @description Detects function/method calls using keyword arguments that don't match
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
from Call callExpr, FunctionObject calledFunc, string badArgName
where
  // Verify the call contains an undefined keyword argument
  illegally_named_parameter_objectapi(callExpr, calledFunc, badArgName)
  and 
  // Exclude abstract methods since their parameters may be defined in implementations
  not calledFunc.isAbstract()
  and 
  // Exclude cases where the argument exists in overridden parent methods
  not exists(FunctionObject overriddenParent |
    calledFunc.overrides(overriddenParent) and
    overriddenParent.getFunction().getAnArg().(Name).getId() = badArgName
  )
// Report the invalid call with contextual information
select callExpr, 
  "Keyword argument '" + badArgName + "' is not a supported parameter name of $@.", 
  calledFunc, 
  calledFunc.descriptiveString()