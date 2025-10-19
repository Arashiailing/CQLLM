/**
 * @name Incorrect parameter name in class constructor call
 * @description Identifies class instantiations where a keyword argument name
 *              does not correspond to any parameter in the class's __init__ method.
 *              This mismatch causes a TypeError during execution.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import essential CodeQL modules for Python code analysis and call argument processing
import python
import Expressions.CallArgs

// This query detects class constructor calls that use keyword arguments
// which do not match any parameter defined in the class's __init__ method
from Call classInstantiation, ClassValue targetClass, string mismatchedArgument, FunctionValue initMethod
where
  // First, verify the presence of an incorrectly named parameter in the constructor call
  illegally_named_parameter(classInstantiation, targetClass, mismatchedArgument) and
  // Then, obtain the initialization method (__init__) of the target class
  initMethod = get_function_or_initializer(targetClass)
select classInstantiation, 
  "Keyword argument '" + mismatchedArgument + "' is not a supported parameter name of $@.", 
  initMethod,
  // Include the fully qualified name of the initialization method for reference
  initMethod.getQualifiedName()