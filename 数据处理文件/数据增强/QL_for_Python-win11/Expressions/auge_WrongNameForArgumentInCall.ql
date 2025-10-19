/**
 * @name Incorrect keyword argument name in function call
 * @description Identifies function calls using named arguments that don't match
 *              any parameter of the target function, which causes runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-argument
 */

import python  // Core Python analysis module
import Expressions.CallArgs  // Handles function call argument analysis

// Identify problematic function calls with mismatched argument names
from Call funcCall, FunctionObject targetFunc, string argName
where
  // Check for argument name mismatch using API predicate
  illegally_named_parameter_objectapi(funcCall, targetFunc, argName) and
  // Exclude abstract functions that might have incomplete signatures
  not targetFunc.isAbstract() and
  // Verify no overridden function accepts the argument name
  not exists(FunctionObject overriddenFunc |
    targetFunc.overrides(overriddenFunc) and 
    overriddenFunc.getFunction().getAnArg().(Name).getId() = argName
  )
select 
  funcCall, 
  "Keyword argument '" + argName + "' is not a supported parameter name of $@.", 
  targetFunc, 
  targetFunc.descriptiveString()