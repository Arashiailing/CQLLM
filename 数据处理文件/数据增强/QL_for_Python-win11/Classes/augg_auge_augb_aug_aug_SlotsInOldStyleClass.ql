/**
 * @name `__slots__` in old-style class
 * @description Detects legacy classes not inheriting from 'object' (old-style) 
 *              that define `__slots__`. In old-style classes, `__slots__` doesn't 
 *              provide memory optimization and functions as a regular attribute, 
 *              potentially causing unexpected behavior. This is critical during 
 *              Python 2.x to 3.x migration due to behavioral differences in `__slots__`.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject oldStyleClassWithSlots
where 
  // Confirm successful class analysis without inference failures
  not oldStyleClassWithSlots.failedInference()
  and
  // Identify classes not inheriting from 'object' (old-style)
  not oldStyleClassWithSlots.isNewStyle() 
  and 
  // Check for explicit __slots__ attribute definition
  oldStyleClassWithSlots.declaresAttribute("__slots__") 
select oldStyleClassWithSlots,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."