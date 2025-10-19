/**
 * @name Incorrect argument name in class constructor call
 * @description Identifies class instantiations using keyword arguments with names
 *              that don't correspond to any parameters in the class's __init__ method.
 *              These mismatches trigger TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import required Python and call argument analysis modules
import python
import Expressions.CallArgs

// Identify problematic class instantiations with mismatched argument names
from Call classInstantiation, ClassValue targetClass, string mismatchedArgName, FunctionValue classInitializer
where
  // Detect calls with incorrectly named parameters
  illegally_named_parameter(classInstantiation, targetClass, mismatchedArgName) and
  // Retrieve the class initializer for error reporting
  classInitializer = get_function_or_initializer(targetClass)
select classInstantiation, "Keyword argument '" + mismatchedArgName + "' is not a supported parameter name of $@.", classInitializer,
  // Report the problematic call, error message, initializer method, and its qualified name
  classInitializer.getQualifiedName()