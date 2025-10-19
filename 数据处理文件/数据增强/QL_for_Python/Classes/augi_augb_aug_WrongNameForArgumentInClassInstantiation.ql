/**
 * @name Wrong name for an argument in a class instantiation
 * @description Identifies class instantiations using named arguments that don't match
 *              any parameter in the class's __init__ method, leading to runtime TypeErrors.
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
from Call classInstantiationCall, ClassValue targetClass, string invalidArgumentName, FunctionValue initializerMethod
where
  // Detect calls containing illegally named parameters
  illegally_named_parameter(classInstantiationCall, targetClass, invalidArgumentName)
  and
  // Resolve the target class's initialization method
  initializerMethod = get_function_or_initializer(targetClass)
select 
  // Report location: problematic class instantiation call
  classInstantiationCall, 
  // Error message: specify the invalid argument name
  "Keyword argument '" + invalidArgumentName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method containing valid parameters
  initializerMethod,
  // Fully qualified name of the initialization method
  initializerMethod.getQualifiedName()