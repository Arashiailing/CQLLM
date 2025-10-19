/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations using named arguments that don't match 
 *              any parameter in the class's __init__ method, which causes runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

import python
import Expressions.CallArgs

// Identify class instantiation calls with invalid keyword arguments
from Call classCall, ClassValue targetClass, string wrongArgName, FunctionValue initMethod
where
  // Verify existence of illegally named parameter in the call
  illegally_named_parameter(classCall, targetClass, wrongArgName) and
  // Retrieve the initialization method of the target class
  initMethod = get_function_or_initializer(targetClass)
select 
  // Report location: problematic class instantiation
  classCall, 
  // Error message: specify unsupported argument name
  "Keyword argument '" + wrongArgName + "' is not a supported parameter name of $@.", 
  // Related element: initialization method
  initMethod,
  // Qualified name of the initialization method
  initMethod.getQualifiedName()