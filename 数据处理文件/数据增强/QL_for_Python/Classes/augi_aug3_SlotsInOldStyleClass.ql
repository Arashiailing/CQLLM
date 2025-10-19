/**
 * @name `__slots__` in old-style class
 * @description Detects old-style Python classes that declare `__slots__`. 
 *              Old-style classes (not inheriting from `object`) ignore `__slots__` semantics,
 *              treating it as a regular class attribute instead of enabling memory optimization.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject cls
where 
  // Confirm class is old-style (non-new-style)
  not cls.isNewStyle() 
  // Check for explicit `__slots__` declaration
  and cls.declaresAttribute("__slots__") 
  // Exclude classes with failed inference
  and not cls.failedInference() 
select cls, 
  "Declaring '__slots__' in an old-style class creates a regular attribute instead of optimizing memory usage."