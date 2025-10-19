/**
 * @name `__slots__` in legacy class
 * @description Identifies legacy classes (not inheriting from 'object') defining `__slots__`.
 *              In legacy classes, `__slots__` doesn't optimize memory and behaves as a 
 *              regular attribute, potentially causing unexpected behavior. This is critical 
 *              during Python 2.x to 3.x migration due to behavioral differences between 
 *              legacy and modern classes regarding `__slots__`.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject legacyClass
where 
  // Verify class analysis completed without inference failures
  not legacyClass.failedInference()
  and
  // Filter classes not inheriting from 'object' (legacy classes)
  not legacyClass.isNewStyle() 
  and 
  // Check for explicit __slots__ attribute definition
  legacyClass.declaresAttribute("__slots__") 
select legacyClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."