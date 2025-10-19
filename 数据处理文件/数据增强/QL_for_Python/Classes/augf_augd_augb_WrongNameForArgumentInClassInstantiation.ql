/**
 * @name Incorrect keyword argument in class instantiation
 * @description Identifies class instantiations using keyword arguments that don't match
 *              any parameter in the class's __init__ method, causing runtime TypeErrors.
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

// Detects class instantiations with invalid keyword argument names
// that don't correspond to any parameter in the class's __init__ method
from Call instanceCall, ClassValue targetClass, string invalidKeyword, FunctionValue initMethod
where
  // Verify presence of an invalid keyword argument in the instantiation
  illegally_named_parameter(instanceCall, targetClass, invalidKeyword) and
  // Obtain the class's initialization method (__init__)
  initMethod = get_function_or_initializer(targetClass)
select instanceCall, 
  "Keyword argument '" + invalidKeyword + "' is not a supported parameter name of $@.", 
  initMethod,
  // Include the qualified name of the initialization method
  initMethod.getQualifiedName()