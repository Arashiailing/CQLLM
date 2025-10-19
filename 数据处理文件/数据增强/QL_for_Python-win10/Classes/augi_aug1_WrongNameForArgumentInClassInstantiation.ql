/**
 * @name Incorrect keyword argument in class instantiation
 * @description Detects class instantiations using keyword arguments 
 *              that don't correspond to any parameter in the class's __init__ method.
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

from Call classCall, ClassValue targetClassValue, string invalidArgumentName, FunctionValue classInitializer
where
  // Identify invalid keyword arguments during class instantiation
  illegally_named_parameter(classCall, targetClassValue, invalidArgumentName) and
  // Retrieve the associated class initializer method
  classInitializer = get_function_or_initializer(targetClassValue)
select classCall, 
       "Keyword argument '" + invalidArgumentName + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()