/**
 * @name Incorrect argument name in class constructor call
 * @description Identifies class instantiation calls that use keyword arguments
 *              with names not matching any parameters in the class's __init__ method.
 *              These mismatches cause TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import required modules for Python code analysis and call argument inspection
import python
import Expressions.CallArgs

// Query to detect class instantiations with invalid keyword argument names
from Call classCreationCall, ClassValue targetClass, string mismatchedArgName, FunctionValue classInitializer
where
  // Identify calls containing incorrectly named parameters
  illegally_named_parameter(classCreationCall, targetClass, mismatchedArgName)
  and
  // Obtain the class constructor for detailed error reporting
  classInitializer = get_function_or_initializer(targetClass)
select classCreationCall, "Keyword argument '" + mismatchedArgName + "' is not a supported parameter name of $@.", classInitializer,
  // Output comprehensive error information including the problematic call, error message,
  // constructor method, and its fully qualified name
  classInitializer.getQualifiedName()