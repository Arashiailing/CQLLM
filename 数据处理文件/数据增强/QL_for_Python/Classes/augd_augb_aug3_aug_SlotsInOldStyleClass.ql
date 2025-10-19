/**
 * @name `__slots__` in old-style class
 * @description Old-style classes (not inheriting from `object`) incorrectly implement 
 *              `__slots__`. Instead of overriding instance dictionary behavior, it creates 
 *              a regular class attribute, defeating memory optimization and causing 
 *              unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject nonNewStyleClass
where 
  // Identify classes not inheriting from object
  not nonNewStyleClass.isNewStyle() 
  // Check for __slots__ attribute declaration
  and nonNewStyleClass.declaresAttribute("__slots__") 
  // Exclude classes with analysis failures
  and not nonNewStyleClass.failedInference()
select nonNewStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."