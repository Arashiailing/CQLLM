/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detect class instantiations that use named arguments which do not match
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

// Identify class instantiation calls with invalid named arguments
from 
  Call classInstantiation,
  ClassValue targetClass,
  string invalidArgName,
  FunctionValue initializerMethod
where
  // Resolve the target class's initialization method
  initializerMethod = get_function_or_initializer(targetClass)
  and
  // Find instance calls containing illegally named parameters
  illegally_named_parameter(classInstantiation, targetClass, invalidArgName)
select 
  // Report location: class instantiation call
  classInstantiation, 
  // Error message: specify unsupported argument name
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initializerMethod,
  // Initialization method's qualified name
  initializerMethod.getQualifiedName()