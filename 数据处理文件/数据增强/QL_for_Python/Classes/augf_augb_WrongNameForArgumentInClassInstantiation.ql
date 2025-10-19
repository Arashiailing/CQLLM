/**
 * @name Wrong name for an argument in a class instantiation
 * @description Identifies class instantiations where a named argument
 *              does not correspond to any parameter in the class's __init__ method.
 *              This mismatch leads to a TypeError during execution.
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

// Query to detect class instantiation calls with incorrectly named keyword arguments
from Call classCreationCall, ClassValue instantiatedClass, string invalidArgName, FunctionValue classInitializer
where
  // Check if the class creation call contains an improperly named argument
  illegally_named_parameter(classCreationCall, instantiatedClass, invalidArgName) and
  // Obtain the initializer function (__init__ method) of the instantiated class
  classInitializer = get_function_or_initializer(instantiatedClass)
select classCreationCall, "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", classInitializer,
  // Return the problematic call, descriptive message, initializer method, and its fully qualified name
  classInitializer.getQualifiedName()