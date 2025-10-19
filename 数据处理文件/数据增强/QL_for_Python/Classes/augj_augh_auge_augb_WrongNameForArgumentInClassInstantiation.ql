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

from Call instantiation, ClassValue cls, string argName, FunctionValue initMethod
where
  // Verify existence of an incorrectly named argument in the instantiation call
  illegally_named_parameter(instantiation, cls, argName) and
  // Retrieve the class's initialization method (__init__ or equivalent)
  initMethod = get_function_or_initializer(cls)
select instantiation, "Keyword argument '" + argName + "' is not a supported parameter name of $@.", initMethod,
  initMethod.getQualifiedName()