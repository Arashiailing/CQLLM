/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations using named arguments that don't match
 *              any parameter in the class's __init__ method, causing runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import Python analysis libraries and call argument utilities
import python
import Expressions.CallArgs

// Identify class instantiations with invalid keyword arguments
from Call classInstCall, ClassValue targetClass, string invalidArgName, FunctionValue initMethod
where
  // Obtain initialization method for the target class
  initMethod = get_function_or_initializer(targetClass) and
  // Verify existence of illegally named parameter in the call
  illegally_named_parameter(classInstCall, targetClass, invalidArgName)
select 
  // Report location: class instantiation call
  classInstCall, 
  // Error message: specify unsupported parameter name
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initMethod,
  // Qualified name of initialization method
  initMethod.getQualifiedName()