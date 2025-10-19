/**
 * @name Mismatched keyword argument in class instantiation
 * @description Detects class instantiations using keyword arguments that don't match
 *              any parameter in the class's __init__ method, leading to runtime TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

import python
import Expressions.CallArgs

// Identify class instantiations with keyword arguments
// that don't correspond to any parameter in the class's __init__ method
from Call classInstantiation, ClassValue instantiatedClass, string invalidArgName, FunctionValue initializer
where
  // Check for presence of an invalid keyword argument
  illegally_named_parameter(classInstantiation, instantiatedClass, invalidArgName) and
  // Retrieve the class's initialization method (__init__)
  initializer = get_function_or_initializer(instantiatedClass)
select classInstantiation, 
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  initializer,
  // Include the qualified name of the initialization method
  initializer.getQualifiedName()