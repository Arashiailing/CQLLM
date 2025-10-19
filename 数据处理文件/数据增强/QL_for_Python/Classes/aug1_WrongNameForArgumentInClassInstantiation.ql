/**
 * @name Wrong name for an argument in a class instantiation
 * @description Identifies class instantiations using keyword arguments 
 *              that don't match any parameter in the class's __init__ method.
 *              Such mismatches cause runtime TypeErrors.
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

from Call classInstantiation, ClassValue targetClass, string invalidArgName, FunctionValue initializerMethod
where
  // Identify invalid keyword arguments in class instantiation
  illegally_named_parameter(classInstantiation, targetClass, invalidArgName) and
  // Retrieve the class's initializer method
  initializerMethod = get_function_or_initializer(targetClass)
select classInstantiation, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initializerMethod,
       initializerMethod.getQualifiedName()