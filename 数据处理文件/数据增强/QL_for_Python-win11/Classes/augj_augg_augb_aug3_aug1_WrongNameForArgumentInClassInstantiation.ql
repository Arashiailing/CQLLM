/**
 * @name Invalid keyword argument in class instantiation
 * @description Identifies class instantiation calls using keyword arguments that don't match 
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

from Call instanceCall, ClassValue targetClass, string invalidKeywordArg, FunctionValue initializerMethod
where
  // Check for keyword arguments that don't match any formal parameter
  illegally_named_parameter(instanceCall, targetClass, invalidKeywordArg)
  and
  // Resolve the class's initialization method (__init__ or constructor equivalent)
  initializerMethod = get_function_or_initializer(targetClass)
select instanceCall, 
       "Keyword argument '" + invalidKeywordArg + "' is not a supported parameter name of $@.", 
       initializerMethod,
       initializerMethod.getQualifiedName()