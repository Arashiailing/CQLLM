/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations using keyword arguments that do not match 
 *              any parameter in the class's __init__ method, which causes runtime TypeErrors.
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

from Call instanceCall, ClassValue targetCls, string invalidArg, FunctionValue initMethod
where
  // Identify class instantiations with invalid keyword arguments
  illegally_named_parameter(instanceCall, targetCls, invalidArg) and
  // Retrieve the corresponding initializer method for the target class
  initMethod = get_function_or_initializer(targetCls)
select instanceCall, 
       "Keyword argument '" + invalidArg + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()