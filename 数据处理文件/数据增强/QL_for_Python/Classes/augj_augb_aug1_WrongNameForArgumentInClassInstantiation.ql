/**
 * @name Incorrect keyword argument in class instantiation
 * @description Identifies class instantiations using a keyword argument 
 *              that doesn't match any parameter in the class's __init__ method.
 *              This causes a TypeError at runtime.
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

from Call objCreation, ClassValue targetClass, string invalidArgName, FunctionValue initializer
where
  // Find invalid keyword arguments during class instantiation
  illegally_named_parameter(objCreation, targetClass, invalidArgName) and
  // Retrieve the class initializer method
  initializer = get_function_or_initializer(targetClass)
select objCreation, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initializer,
       initializer.getQualifiedName()