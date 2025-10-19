/**
 * @name `__slots__` in old-style class
 * @description Python's old-style classes (those not inheriting from 'object') lack support
 *              for the `__slots__` optimization feature. When `__slots__` is defined in such
 *              classes, it behaves as a regular class attribute without providing memory benefits.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python  // Import the Python library to access Python code elements

from ClassObject problematicClass  // Identify a class for potential analysis
where 
  // Confirm the class is properly inferred
  not problematicClass.failedInference() 
  // Identify old-style classes (not inheriting from object)
  and not problematicClass.isNewStyle() 
  // Check for the presence of __slots__ attribute
  and problematicClass.declaresAttribute("__slots__") 
select problematicClass,  // The class that violates the best practice
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'." 
  // Explanatory message about the ineffective use of __slots__