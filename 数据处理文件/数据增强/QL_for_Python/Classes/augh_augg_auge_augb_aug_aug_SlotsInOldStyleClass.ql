/**
 * @name `__slots__` in old-style class
 * @description Identifies legacy classes (not inheriting from 'object') that define `__slots__`. 
 *              In old-style classes, `__slots__` doesn't provide memory optimization and 
 *              functions as a regular attribute, potentially causing unexpected behavior. 
 *              This is critical during Python 2.x to 3.x migration due to behavioral differences.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject legacyClassWithSlots
where 
  // Ensure class analysis completed successfully without inference failures
  not legacyClassWithSlots.failedInference()
  and
  // Filter for classes not inheriting from 'object' (old-style classes)
  not legacyClassWithSlots.isNewStyle() 
  and 
  // Verify explicit declaration of __slots__ attribute
  legacyClassWithSlots.declaresAttribute("__slots__") 
select legacyClassWithSlots,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."