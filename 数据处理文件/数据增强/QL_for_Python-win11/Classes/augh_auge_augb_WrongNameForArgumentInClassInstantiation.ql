/**
 * @name Incorrect named argument in class instantiation
 * @description Identifies class instantiations using keyword arguments
 *              that don't match any parameter in the class's __init__ method.
 *              This causes a TypeError at runtime.
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

from Call classInstantiation, ClassValue targetClass, string invalidArgumentName, FunctionValue initializerMethod
where
  // Retrieve the class's initialization method (__init__ or equivalent)
  initializerMethod = get_function_or_initializer(targetClass) and
  // Verify existence of an incorrectly named argument in the instantiation call
  illegally_named_parameter(classInstantiation, targetClass, invalidArgumentName)
select classInstantiation, "Keyword argument '" + invalidArgumentName + "' is not a supported parameter name of $@.", initializerMethod,
  initializerMethod.getQualifiedName()