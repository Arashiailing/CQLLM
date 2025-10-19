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

// This query identifies class instantiations using invalid keyword argument names
// that don't correspond to any parameter in the class's __init__ method
from Call instantiationCall, ClassValue instantiatedClass, string invalidArgName, FunctionValue classInitializer
where
  // Check for presence of an invalid keyword argument in the instantiation
  illegally_named_parameter(instantiationCall, instantiatedClass, invalidArgName) and
  // Retrieve the class's initialization method (__init__)
  classInitializer = get_function_or_initializer(instantiatedClass)
select instantiationCall, 
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  classInitializer,
  // Include the qualified name of the initialization method
  classInitializer.getQualifiedName()