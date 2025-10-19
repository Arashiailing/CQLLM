/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations that use named arguments which do not
 *              correspond to any parameter in the class's __init__ method.
 *              Such usage leads to TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import necessary Python and expression call argument modules
import python
import Expressions.CallArgs

// Query for class instantiations with invalid named arguments
from Call classInstantiation, ClassValue targetClass, string invalidArgName, FunctionValue initializerMethod
where
  // Verify if the call uses an illegally named parameter for the class
  illegally_named_parameter(classInstantiation, targetClass, invalidArgName) and
  // Retrieve the initializer method (__init__) of the target class
  initializerMethod = get_function_or_initializer(targetClass)
select classInstantiation, "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", initializerMethod,
  // Output the class instantiation, error message, initializer method, and its qualified name
  initializerMethod.getQualifiedName()