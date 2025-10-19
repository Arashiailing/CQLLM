/**
 * @name Wrong name for an argument in a class instantiation
 * @description Identifies class instantiations using keyword arguments that don't match 
 *              any parameter in the class's __init__ method, leading to runtime TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

import python
import Expressions.CallArgs

from Call classInstantiation, ClassValue instantiatedClass, string mismatchedParam, FunctionValue classInitializer
where
  // Find class instantiations with invalid keyword arguments
  illegally_named_parameter(classInstantiation, instantiatedClass, mismatchedParam) and
  // Retrieve the initializer method (__init__) of the target class
  classInitializer = get_function_or_initializer(instantiatedClass)
select classInstantiation, 
       "Keyword argument '" + mismatchedParam + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()