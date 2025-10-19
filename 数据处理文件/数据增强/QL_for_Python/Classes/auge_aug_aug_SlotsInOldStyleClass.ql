/**
 * @name `__slots__` in old-style class
 * @description Detects legacy classes (non-new-style) that declare `__slots__`. 
 *              In such contexts, `__slots__` functions as a standard attribute rather 
 *              than providing memory optimization, causing unexpected behavior and 
 *              performance degradation.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject oldStyleClass
where 
  // Verify class analysis completed successfully
  not oldStyleClass.failedInference() 
  and 
  // Identify classes not inheriting from object (old-style)
  not oldStyleClass.isNewStyle() 
  and 
  // Check for explicit __slots__ attribute declaration
  oldStyleClass.declaresAttribute("__slots__") 
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."