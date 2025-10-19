/**
 * @name `__slots__` in old-style class
 * @description Identifies legacy classes (not inheriting from object) utilizing `__slots__`. 
 *              This pattern creates a regular attribute instead of enabling memory optimization, 
 *              resulting in unexpected behavior and performance degradation.
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
  // Verify class represents an old-style (non-new-style) class
  not targetClass.isNewStyle() 
  and 
  // Confirm class explicitly defines __slots__ attribute
  targetClass.declaresAttribute("__slots__") 
  and 
  // Ensure class analysis completed successfully
  not targetClass.failedInference()
select targetClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."