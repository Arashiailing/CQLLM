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

// Find class constructor calls with mismatched named parameters
from Call classConstructorCall, ClassValue targetClass, string invalidParamName, FunctionValue classInitializer
where
  // Identify constructor calls containing invalid named parameters
  illegally_named_parameter(classConstructorCall, targetClass, invalidParamName)
  and
  // Obtain the initialization method of the target class
  classInitializer = get_function_or_initializer(targetClass)
select 
  // Error location: class constructor call
  classConstructorCall, 
  // Error description: specify the invalid parameter name
  "Keyword argument '" + invalidParamName + "' is not a valid parameter name for $@.", 
  // Associated element: constructor method
  classInitializer,
  // Fully qualified name of the constructor method
  classInitializer.getQualifiedName()