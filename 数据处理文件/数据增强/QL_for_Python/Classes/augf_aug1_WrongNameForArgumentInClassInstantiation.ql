/**
 * @name Incorrect keyword argument in class instantiation
 * @description Detects class instantiations that use keyword arguments
 *              which do not correspond to any parameter in the class's __init__ method.
 *              These mismatches result in runtime TypeErrors.
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

from Call classCreation, ClassValue instantiatedClass, string invalidParameterName, FunctionValue classInitializer
where
  // First, find the initializer method of the target class
  classInitializer = get_function_or_initializer(instantiatedClass) and
  // Then, identify any keyword arguments in the class instantiation that don't match parameters
  illegally_named_parameter(classCreation, instantiatedClass, invalidParameterName)
select classCreation, 
       "Keyword argument '" + invalidParameterName + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()