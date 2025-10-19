/**
 * @name Incorrect keyword argument in class instantiation
 * @description This query identifies class instantiations that use keyword arguments
 *              which do not match any parameter in the class's __init__ method.
 *              Such usage leads to TypeError exceptions during runtime execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import necessary Python analysis libraries and call argument modules
import python
import Expressions.CallArgs

// Identify class instantiation calls with invalid named arguments
from Call classInstanceCall, ClassValue instantiatedClass, string unsupportedArgName, FunctionValue classInitializer
where
  // Verify that the call contains an improperly named parameter
  illegally_named_parameter(classInstanceCall, instantiatedClass, unsupportedArgName) and
  // Retrieve the initialization method of the target class
  classInitializer = get_function_or_initializer(instantiatedClass)
select 
  // Report location: the class instantiation call
  classInstanceCall, 
  // Error message: specify which argument name is not supported
  "Keyword argument '" + unsupportedArgName + "' is not a supported parameter name of $@.", 
  // Related element: the initialization method
  classInitializer,
  // Qualified name of the initialization method
  classInitializer.getQualifiedName()