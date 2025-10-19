/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects when a named argument is used in a class instantiation
 *              that does not match any parameter of the class's __init__ method.
 *              This results in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import required CodeQL modules for Python analysis and call arguments handling
import python
import Expressions.CallArgs

// Query to identify class instantiations with incorrectly named keyword arguments
from Call instanceCreation, ClassValue referencedClass, string paramName, FunctionValue initMethod
where
  // First, retrieve the class's __init__ method or initializer function
  initMethod = get_function_or_initializer(referencedClass) and
  // Then, verify the presence of an illegally named parameter in the instantiation call
  illegally_named_parameter(instanceCreation, referencedClass, paramName)
select instanceCreation, "Keyword argument '" + paramName + "' is not a supported parameter name of $@.", initMethod,
  // Return the problematic call, descriptive message, initializer method, and its qualified name
  initMethod.getQualifiedName()