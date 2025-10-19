/**
 * @name Invalid keyword argument in class instantiation
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

from Call classInstanceCall, ClassValue targetClass, string invalidArgName, FunctionValue initializerMethod
where
  // Detect invalid keyword arguments in class instantiation
  illegally_named_parameter(classInstanceCall, targetClass, invalidArgName) and
  // Resolve the initializer method for the target class
  initializerMethod = get_function_or_initializer(targetClass)
select classInstanceCall, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initializerMethod,
       initializerMethod.getQualifiedName()