/**
 * @name `__slots__` in old-style class
 * @description Detects old-style classes (not inheriting from object) that use `__slots__`. 
 *              In such cases, `__slots__` behaves as a regular attribute instead of optimizing 
 *              memory usage, leading to unintended behavior and inefficiency.
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
  // Identify non-new-style classes (old-style)
  not cls.isNewStyle() 
  and 
  // Check if class declares __slots__ attribute
  cls.declaresAttribute("__slots__") 
  and 
  // Ensure class analysis was successful
  not cls.failedInference()
select cls,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."