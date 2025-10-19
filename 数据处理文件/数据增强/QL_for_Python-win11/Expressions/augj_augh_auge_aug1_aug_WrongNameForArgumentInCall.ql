/**
 * @name Incorrect keyword argument in function invocation
 * @description Detects function/method calls that utilize keyword arguments which do not correspond
 *              to any parameter names defined in the target function. These naming mismatches
 *              result in runtime TypeErrors when the code is executed.
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

// Identify function invocations containing keyword arguments with invalid names
from Call functionCall, FunctionObject targetFunction, string mismatchedParamName
where
  // Core condition: Verify that the call uses a keyword argument not defined in the target function
  illegally_named_parameter_objectapi(functionCall, targetFunction, mismatchedParamName)
  and 
  // Filter out abstract methods since their parameter definitions may reside in concrete implementations
  not targetFunction.isAbstract()
  and 
  // Exclude scenarios where the argument name exists in overridden parent class methods
  not exists(FunctionObject parentMethod |
    targetFunction.overrides(parentMethod) and
    parentMethod.getFunction().getAnArg().(Name).getId() = mismatchedParamName
  )
// Generate alert for the problematic function call with relevant contextual details
select functionCall, 
  "Keyword argument '" + mismatchedParamName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()