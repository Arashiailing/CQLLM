/**
 * @name Incorrect keyword argument in class instantiation
 * @description Detects class instantiations that use a keyword argument 
 *              which does not correspond to any parameter in the class's __init__ method.
 *              This leads to a TypeError at runtime.
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

from Call instantiation, ClassValue cls, string wrongArgName, FunctionValue initMethod
where
  // Locate invalid keyword arguments during class instantiation
  illegally_named_parameter(instantiation, cls, wrongArgName) and
  // Obtain the class initializer method
  initMethod = get_function_or_initializer(cls)
select instantiation, 
       "Keyword argument '" + wrongArgName + "' is not a supported parameter name of $@.", 
       initMethod,
       initMethod.getQualifiedName()