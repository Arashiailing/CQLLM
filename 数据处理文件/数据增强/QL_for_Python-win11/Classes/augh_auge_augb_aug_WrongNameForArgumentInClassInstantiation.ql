/**
 * @name Incorrect named argument in class constructor call
 * @description Identifies class instantiation calls that use keyword arguments
 *              not defined in the class constructor, leading to runtime TypeErrors.
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

// Identify class instantiation calls with invalid named parameters
from Call classInstantiationCall, ClassValue targetClass, string invalidParamName, FunctionValue classInitializer
where
  // Detect constructor calls containing undefined named parameters
  illegally_named_parameter(classInstantiationCall, targetClass, invalidParamName)
  and
  // Resolve the initialization method of the target class
  classInitializer = get_function_or_initializer(targetClass)
select 
  // Error location: class constructor call
  classInstantiationCall, 
  // Error description: specify the invalid parameter name
  "Keyword argument '" + invalidParamName + "' is not a valid parameter name for $@.", 
  // Associated element: constructor method
  classInitializer,
  // Fully qualified name of the constructor method
  classInitializer.getQualifiedName()