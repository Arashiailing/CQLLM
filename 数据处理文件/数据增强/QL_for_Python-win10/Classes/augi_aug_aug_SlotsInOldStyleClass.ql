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

from ClassObject targetClass
where 
  // Verify class analysis was successful before proceeding
  not targetClass.failedInference()
  and 
  // Identify classes not inheriting from object (old-style)
  not targetClass.isNewStyle()
  and 
  // Check for presence of __slots__ attribute declaration
  targetClass.declaresAttribute("__slots__")
select targetClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."