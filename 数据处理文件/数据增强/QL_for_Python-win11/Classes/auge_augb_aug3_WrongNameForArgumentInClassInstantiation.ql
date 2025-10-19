/**
 * @name Incorrect argument name in class constructor call
 * @description Detects class instantiation calls using keyword arguments with names
 *              that do not match any parameters in the class's __init__ method.
 *              Such mismatches result in TypeError exceptions during execution.
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

// Main query: Find class instantiations with invalid keyword argument names
from Call classInstanceCall, ClassValue instantiatedClass, string invalidArgName, FunctionValue constructorMethod
where
  // First condition: Check for calls with incorrectly named parameters
  illegally_named_parameter(classInstanceCall, instantiatedClass, invalidArgName)
  and
  // Second condition: Retrieve the class constructor for error reporting
  constructorMethod = get_function_or_initializer(instantiatedClass)
select classInstanceCall, "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", constructorMethod,
  // Generate the error report including the problematic call, error message, constructor method, and its qualified name
  constructorMethod.getQualifiedName()