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
from Call constructorCall, ClassValue instantiatedClass, string mismatchedParamName, FunctionValue constructorMethod
where
  // Detect constructor calls containing invalid named parameters
  illegally_named_parameter(constructorCall, instantiatedClass, mismatchedParamName)
  and
  // Retrieve the initialization method of the target class
  constructorMethod = get_function_or_initializer(instantiatedClass)
select 
  // Error location: class constructor call
  constructorCall, 
  // Error description: specify the invalid parameter name
  "Keyword argument '" + mismatchedParamName + "' is not a valid parameter name for $@.", 
  // Associated element: constructor method
  constructorMethod,
  // Fully qualified name of the constructor method
  constructorMethod.getQualifiedName()