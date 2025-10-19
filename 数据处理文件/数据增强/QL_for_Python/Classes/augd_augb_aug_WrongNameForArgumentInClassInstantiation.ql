/**
 * @name Incorrect named argument in class instantiation
 * @description Identifies class instantiations using named arguments that don't correspond
 *              to any parameter in the class's __init__ method, leading to runtime TypeErrors.
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

// Identify problematic class instantiations with invalid named arguments
from Call instantiationCall, ClassValue targetClass, string invalidArgumentName, FunctionValue initializerMethod
where
  // Locate class instantiations containing unrecognized named parameters
  illegally_named_parameter(instantiationCall, targetClass, invalidArgumentName)
  and
  // Resolve the initialization method of the target class
  initializerMethod = get_function_or_initializer(targetClass)
select 
  // Report location: problematic class instantiation call
  instantiationCall, 
  // Error message: specify the unsupported argument name
  "Keyword argument '" + invalidArgumentName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initializerMethod,
  // Initialization method's qualified name
  initializerMethod.getQualifiedName()