/**
 * @name Incorrect named argument in class instantiation
 * @description Identifies class instantiations using named arguments that don't correspond
 *              to any parameter in the class's __init__ method, leading to runtime TypeError.
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

// Find class instantiations with mismatched keyword arguments
from Call classInvocation, ClassValue instantiatedClass, string unsupportedArgName, FunctionValue initializerMethod
where
  // Retrieve the initialization method for the instantiated class
  initializerMethod = get_function_or_initializer(instantiatedClass) and
  // Check for existence of invalid parameter name in the call
  illegally_named_parameter(classInvocation, instantiatedClass, unsupportedArgName)
select 
  // Report location: class instantiation call
  classInvocation, 
  // Error message: specify unsupported parameter name
  "Keyword argument '" + unsupportedArgName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initializerMethod,
  // Qualified name of initialization method
  initializerMethod.getQualifiedName()