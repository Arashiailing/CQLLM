/**
 * @name Invalid keyword argument in class instantiation
 * @description Identifies class instantiations using keyword arguments that don't correspond 
 *              to any parameter in the class's __init__ method, leading to runtime TypeErrors.
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

from Call classCall, ClassValue cls, string invalidArg, FunctionValue initMethod
where
  // Obtain the initializer method (__init__) for the target class
  initMethod = get_function_or_initializer(cls)
  and
  // Verify existence of invalid keyword arguments in class instantiation
  illegally_named_parameter(classCall, cls, invalidArg)
select classCall, 
       "Keyword argument '" + invalidArg + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()