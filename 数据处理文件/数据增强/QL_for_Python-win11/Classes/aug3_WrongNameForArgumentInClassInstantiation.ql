/**
 * @name Incorrect argument name in class constructor call
 * @description This query detects class instantiations that use keyword arguments
 *              with names that don't match any parameters in the class's __init__ method.
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

// Import necessary Python and call argument analysis modules
import python
import Expressions.CallArgs

// Query to find problematic class instantiations with mismatched argument names
from Call instantiation, ClassValue targetClass, string argName, FunctionValue initializer
where
  // First, identify calls with incorrectly named parameters
  illegally_named_parameter(instantiation, targetClass, argName) and
  // Then, retrieve the class initializer for error reporting
  initializer = get_function_or_initializer(targetClass)
select instantiation, "Keyword argument '" + argName + "' is not a supported parameter name of $@.", initializer,
  // Report the problematic call, error message, initializer method, and its qualified name
  initializer.getQualifiedName()