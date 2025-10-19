/**
 * @name Incorrect named argument in class instantiation
 * @description Identifies class instantiations using named arguments that don't correspond
 *              to any parameter in the class's __init__ method, leading to runtime TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-class-argument
 */

// Import necessary modules for Python code analysis and call argument evaluation
import python
import Expressions.CallArgs

// Identify class instantiation calls with invalid named parameters
from Call problematicInstantiation, ClassValue targetClass, string invalidArgName, FunctionValue initMethod
where
  // Locate class instantiations that contain unrecognized named parameters
  illegally_named_parameter(problematicInstantiation, targetClass, invalidArgName)
  and
  // Retrieve the initialization method (__init__) of the target class
  initMethod = get_function_or_initializer(targetClass)
select 
  // Report the location of the problematic class instantiation
  problematicInstantiation, 
  // Generate error message specifying the unsupported argument
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  // Reference the initialization method for additional context
  initMethod,
  // Include the qualified name of the initialization method in the report
  initMethod.getQualifiedName()