/**
 * @name Invalid keyword argument in class instantiation
 * @description Detects class instantiations using keyword arguments that don't match 
 *              any parameter in the class's __init__ method, which will cause runtime TypeErrors.
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

from Call instanceCall, ClassValue instantiatedClass, string invalidArgName, FunctionValue initMethod
where
  // Obtain the initializer method for the target class
  initMethod = get_function_or_initializer(instantiatedClass)
  and
  // Identify class instantiations containing invalid keyword arguments
  illegally_named_parameter(instanceCall, instantiatedClass, invalidArgName)
select instanceCall, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()