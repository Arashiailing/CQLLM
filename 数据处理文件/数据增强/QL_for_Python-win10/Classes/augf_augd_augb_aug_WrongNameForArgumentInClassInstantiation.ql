/**
 * @name Incorrect named argument in class instantiation
 * @description Detects class instantiation calls that use named arguments which do not match
 *              any parameter defined in the class's __init__ method, potentially causing
 *              runtime TypeError exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import necessary modules for Python code analysis and call argument handling
import python
import Expressions.CallArgs

// Query to find class instantiations with invalid named arguments
from Call classInstantiation, ClassValue instantiatedClass, string invalidArgName, FunctionValue initMethod
where
  // Find class instantiations that contain unrecognized named parameters
  illegally_named_parameter(classInstantiation, instantiatedClass, invalidArgName)
  and
  // Retrieve the initialization method of the target class
  initMethod = get_function_or_initializer(instantiatedClass)
select 
  // Location of the problematic class instantiation call
  classInstantiation, 
  // Detailed error message indicating the unsupported argument
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  // Reference to the initialization method for context
  initMethod,
  // Fully qualified name of the initialization method
  initMethod.getQualifiedName()