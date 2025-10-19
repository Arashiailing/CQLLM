/**
 * @name Invalid keyword argument in class instantiation
 * @description Detects class instantiations that use keyword arguments which do not correspond
 *              to any parameter in the class's __init__ method, potentially causing runtime TypeErrors.
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

from Call classInstantiation, ClassValue targetClass, string invalidArgName, FunctionValue initMethod
where
  // Step 1: Resolve the initializer method for the target class
  initMethod = get_function_or_initializer(targetClass) and
  // Step 2: Identify invalid keyword arguments in class instantiation
  illegally_named_parameter(classInstantiation, targetClass, invalidArgName)
select classInstantiation, 
       "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()