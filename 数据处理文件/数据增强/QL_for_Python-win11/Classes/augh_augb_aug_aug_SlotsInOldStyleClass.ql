/**
 * @name `__slots__` in old-style class
 * @description Identifies classes that do not inherit from 'object' (old-style classes) 
 *              yet define the `__slots__` attribute. In Python, old-style classes 
 *              cannot leverage the memory optimization benefits of `__slots__`. Instead,
 *              it merely creates a regular class attribute, leading to unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject problematicClass
where 
  // Ensure class analysis completed successfully
  not problematicClass.failedInference()
  and 
  // Confirm it's an old-style class
  not problematicClass.isNewStyle() 
  and 
  // Check for __slots__ definition
  problematicClass.declaresAttribute("__slots__")
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."