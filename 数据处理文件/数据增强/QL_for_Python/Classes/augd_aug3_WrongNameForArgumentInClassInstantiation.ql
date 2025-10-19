/**
 * @name Incorrect argument name in class constructor call
 * @description Identifies class instantiation calls that employ keyword arguments
 *              with names not corresponding to any parameters in the class's __init__ method.
 *              These discrepancies lead to TypeError exceptions during execution.
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

// Query for locating class instantiations with incorrectly named keyword arguments
from Call classCall, ClassValue instantiatedClass, string parameterName, FunctionValue classInitializer
where
  // Identify calls containing incorrectly named keyword arguments
  illegally_named_parameter(classCall, instantiatedClass, parameterName) and
  // Obtain the class initializer for reporting purposes
  classInitializer = get_function_or_initializer(instantiatedClass)
select
  // The problematic class instantiation call
  classCall, 
  // Error message indicating the incorrect parameter name
  "Keyword argument '" + parameterName + "' is not a supported parameter name of $@.", 
  // The class initializer method
  classInitializer,
  // Qualified name of the initializer method
  classInitializer.getQualifiedName()