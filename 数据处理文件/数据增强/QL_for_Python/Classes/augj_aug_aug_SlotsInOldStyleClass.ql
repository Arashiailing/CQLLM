/**
 * @name `__slots__` in old-style class
 * @description Identifies old-style classes (not inheriting from object) that define `__slots__`. 
 *              In such classes, `__slots__` behaves as a regular attribute rather than providing 
 *              memory optimization, causing unintended behavior and performance issues.
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
  // Verify class is old-style (non-new-style)
  not problematicClass.isNewStyle() 
  and 
  // Check for explicit __slots__ attribute declaration
  problematicClass.declaresAttribute("__slots__") 
  and 
  // Confirm class analysis completed successfully
  not problematicClass.failedInference()
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."