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

// Import core Python analysis modules and call argument inspection utilities
import python
import Expressions.CallArgs

// Identify class instantiations containing incorrectly named keyword arguments
from 
  Call classInstantiation, 
  ClassValue targetClass, 
  string mismatchedArgName, 
  FunctionValue initializerMethod
where 
  // First obtain the class initializer method for error context
  initializerMethod = get_function_or_initializer(targetClass)
  and 
  // Then detect keyword arguments that don't match any __init__ parameters
  illegally_named_parameter(classInstantiation, targetClass, mismatchedArgName)
select 
  classInstantiation,
  "Keyword argument '" + mismatchedArgName + "' is not a supported parameter name of $@.",
  initializerMethod,
  initializerMethod.getQualifiedName()