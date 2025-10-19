/**
 * @name Wrong name for an argument in a class instantiation
 * @description Detects class instantiations using a keyword argument name
 *              that does not match any parameter in the class's __init__ method.
 *              Such usage will raise a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import Python analysis libraries and call argument utilities
import python
import Expressions.CallArgs

// Identify class instantiations with invalid keyword argument names
from Call classInst, ClassValue targetCls, string invalidArg, FunctionValue initMethod
where
  // Retrieve the initialization method of the target class
  initMethod = get_function_or_initializer(targetCls) and
  // Verify the presence of an illegally named parameter in the instantiation
  illegally_named_parameter(classInst, targetCls, invalidArg)
select 
  // Report location: the class instantiation call
  classInst, 
  // Error message: specify the unsupported argument name
  "Keyword argument '" + invalidArg + "' is not a supported parameter name of $@.", 
  // Related element: the initialization method
  initMethod,
  // Fully qualified name of the initialization method
  initMethod.getQualifiedName()