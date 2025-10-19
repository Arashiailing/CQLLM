/**
 * @name Invalid keyword argument in class instantiation
 * @description Detects class instantiations using keyword arguments that don't correspond 
 *              to any parameter in the class's __init__ method, which will cause runtime TypeErrors.
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

from Call classInstantiationCall, ClassValue targetClass, string invalidArgName, FunctionValue classInitializer
where
  // Identify keyword arguments that don't match any formal parameter
  illegally_named_parameter(classInstantiationCall, targetClass, invalidArgName)
  and
  // Resolve the class initializer method (__init__ or constructor equivalent)
  classInitializer = get_function_or_initializer(targetClass)
select classInstantiationCall, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()