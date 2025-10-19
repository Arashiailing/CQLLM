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

from Call classInstantiation, ClassValue targetClass, string invalidKeyword, FunctionValue initializerMethod
where
  // Retrieve the initializer method for the target class
  initializerMethod = get_function_or_initializer(targetClass)
  and
  // Identify invalid keyword arguments in the class instantiation
  illegally_named_parameter(classInstantiation, targetClass, invalidKeyword)
select classInstantiation, 
       "Keyword argument '" + invalidKeyword + "' is not a supported parameter name of $@.", 
       initializerMethod,
       initializerMethod.getQualifiedName()