/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations using named arguments that don't match
 *              any parameter in the class's __init__ method, which causes runtime TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import Python analysis and call argument modules
import python
import Expressions.CallArgs

// Identify class instantiation calls with invalid named arguments
from Call instanceCall, ClassValue targetCls, string wrongArgName, FunctionValue initMethod
where
  // Find instance calls containing illegally named parameters
  illegally_named_parameter(instanceCall, targetCls, wrongArgName)
  and
  // Resolve the target class's initialization method
  initMethod = get_function_or_initializer(targetCls)
select 
  // Report location: class instantiation call
  instanceCall, 
  // Error message: specify unsupported argument name
  "Keyword argument '" + wrongArgName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initMethod,
  // Initialization method's qualified name
  initMethod.getQualifiedName()