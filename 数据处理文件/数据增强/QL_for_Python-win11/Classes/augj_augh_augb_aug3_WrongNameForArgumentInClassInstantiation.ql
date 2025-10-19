/**
 * @name Incorrect argument name in class constructor call
 * @description Identifies class instantiations where keyword arguments use names
 *              that don't correspond to any parameters in the class's __init__ method.
 *              These mismatches result in TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import core Python analysis modules and call argument utilities
import python
import Expressions.CallArgs

// Detect class instantiations with mismatched keyword argument names
from Call classInstantiation, ClassValue targetClassValue, string mismatchedArgName, FunctionValue classInitializer
where
  // Capture calls containing incorrectly named parameters
  illegally_named_parameter(classInstantiation, targetClassValue, mismatchedArgName)
  and
  // Retrieve the class initializer for error context
  classInitializer = get_function_or_initializer(targetClassValue)
select
  classInstantiation,
  "Keyword argument '" + mismatchedArgName + "' is not a supported parameter name of $@.",
  classInitializer,
  classInitializer.getQualifiedName()