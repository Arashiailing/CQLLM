/**
 * @name Incorrect argument name in class constructor call
 * @description Detects class instantiations where keyword arguments use names
 *              that don't match any parameters in the class's __init__ method.
 *              Such mismatches cause TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import essential Python and call argument analysis modules
import python
import Expressions.CallArgs

// Identify problematic class instantiations with invalid argument names
from Call constructorCall, ClassValue targetClass, string invalidArgName, FunctionValue initializerMethod
where
  // Locate calls containing incorrectly named parameters
  illegally_named_parameter(constructorCall, targetClass, invalidArgName)
  and
  // Obtain the class initializer for error context
  initializerMethod = get_function_or_initializer(targetClass)
select
  constructorCall,
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.",
  initializerMethod,
  initializerMethod.getQualifiedName()