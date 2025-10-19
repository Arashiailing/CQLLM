/**
 * @name Incorrect argument name in class constructor call
 * @description Detects class instantiation calls that utilize keyword arguments
 *              with names that do not correspond to any parameters in the class's __init__ method.
 *              Such mismatches result in TypeError exceptions during runtime execution.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import necessary modules for Python code analysis and call argument inspection
import python
import Expressions.CallArgs

// Main query: Identify class instantiations with invalid keyword argument names
from Call instantiationCall, ClassValue targetClass, string mismatchedParamName, FunctionValue constructorMethod
where
  // Retrieve the class constructor for error reporting
  constructorMethod = get_function_or_initializer(targetClass)
  and
  // Check for incorrectly named parameters in the instantiation call
  illegally_named_parameter(instantiationCall, targetClass, mismatchedParamName)
select instantiationCall, "Keyword argument '" + mismatchedParamName + "' is not a supported parameter name of $@.", constructorMethod,
  // Generate the error report including the problematic call, error message, constructor method, and its qualified name
  constructorMethod.getQualifiedName()