/**
 * @name Invalid keyword argument in class instantiation
 * @description Detects class instantiations that use keyword arguments which do not correspond
 *              to any parameter in the class's __init__ method, potentially causing runtime TypeErrors.
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

from Call classCreationCall, ClassValue targetClassType, string invalidKeywordArg, FunctionValue classInitializer
where
  // Resolve the initializer method for the target class
  classInitializer = get_function_or_initializer(targetClassType) and
  // Detect invalid keyword arguments in class instantiation
  illegally_named_parameter(classCreationCall, targetClassType, invalidKeywordArg)
select classCreationCall, 
       "Keyword argument '" + invalidKeywordArg + "' is not a supported parameter name of $@.", 
       classInitializer,
       classInitializer.getQualifiedName()