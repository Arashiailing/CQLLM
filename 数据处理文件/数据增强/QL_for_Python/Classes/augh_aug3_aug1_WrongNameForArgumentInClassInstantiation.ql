/**
 * @name Incorrect keyword argument in class instantiation
 * @description Identifies class instantiations using keyword arguments that don't match 
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

from Call instantiationCall, ClassValue targetClass, string invalidArgument, FunctionValue initializerMethod
where
  // Find class instantiations with invalid keyword arguments
  illegally_named_parameter(instantiationCall, targetClass, invalidArgument)
  and
  // Obtain the initializer method for the target class
  initializerMethod = get_function_or_initializer(targetClass)
select instantiationCall, 
       "Keyword argument '" + invalidArgument + "' is not a supported parameter name of $@.", 
       initializerMethod,
       initializerMethod.getQualifiedName()