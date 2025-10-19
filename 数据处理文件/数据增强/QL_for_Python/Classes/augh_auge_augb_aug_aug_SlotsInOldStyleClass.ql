/**
 * @name `__slots__` in old-style class
 * @description Detects legacy classes (not inheriting from 'object') that define `__slots__`.
 *              In old-style classes, `__slots__` doesn't provide memory optimization and
 *              behaves like a regular class attribute, potentially causing unexpected behavior.
 *              This is critical during Python 2.x to 3.x migration due to behavioral differences
 *              between old-style and new-style classes regarding `__slots__`.
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
  // Ensure class analysis completed without inference failures
  not oldStyleClass.failedInference()
  and
  // Identify classes not inheriting from 'object' (old-style)
  not oldStyleClass.isNewStyle() 
  and 
  // Check for explicit __slots__ attribute definition
  oldStyleClass.declaresAttribute("__slots__") 
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."