/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations where keyword arguments don't correspond 
 *              to any parameter in the class's __init__ method, causing runtime TypeErrors.
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

from Call instanceCall, ClassValue targetClass, string invalidArgName, FunctionValue initMethod
where
  // Identify class instantiations containing invalid keyword arguments
  illegally_named_parameter(instanceCall, targetClass, invalidArgName) and
  // Obtain the initializer (__init__) method of the instantiated class
  initMethod = get_function_or_initializer(targetClass)
select instanceCall, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()