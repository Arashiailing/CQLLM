/**
 * @name Incorrect argument name in class constructor call
 * @description Identifies class instantiation calls that use keyword arguments
 *              with names not matching any parameters in the class's __init__ method.
 *              These mismatches lead to TypeError exceptions at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import required modules for Python analysis and call argument examination
import python
import Expressions.CallArgs

// Primary query: Locate class instantiations with invalid keyword argument names
from Call classInstantiation, ClassValue classBeingInstantiated, string invalidParameterName, FunctionValue classConstructor
where
  // Condition 1: Identify calls containing incorrectly named parameters
  illegally_named_parameter(classInstantiation, classBeingInstantiated, invalidParameterName)
  and
  // Condition 2: Obtain the class constructor for error reporting purposes
  classConstructor = get_function_or_initializer(classBeingInstantiated)
select classInstantiation, "Keyword argument '" + invalidParameterName + "' is not a supported parameter name of $@.", classConstructor,
  // Generate the error report including the problematic call, error message, constructor method, and its qualified name
  classConstructor.getQualifiedName()