/**
 * @name Invalid keyword argument in class instantiation
 * @description Detects class instantiations using keyword arguments that don't correspond
 *              to any parameter in the class's __init__ method, causing runtime TypeErrors.
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

from Call classCreationCall, ClassValue instantiatedClass, string invalidKeywordArg, FunctionValue classInitializer
where
  // Identify class instantiation calls with invalid keyword arguments
  illegally_named_parameter(classCreationCall, instantiatedClass, invalidKeywordArg) and
  // Resolve the class initializer method (__init__ or __new__)
  classInitializer = get_function_or_initializer(instantiatedClass)
select classCreationCall, 
       "Keyword argument '" + invalidKeywordArg + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()