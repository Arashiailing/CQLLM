/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes that declare `__slots__` do not achieve memory optimization
 *              since `__slots__` merely creates a regular class attribute rather than replacing
 *              the instance dictionary.
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
  // Filter for old-style classes (those not inheriting from object)
  not targetClass.isNewStyle() 
  and 
  // Check if the class declares __slots__ attribute
  targetClass.declaresAttribute("__slots__") 
  and 
  // Ensure the class analysis succeeded
  not targetClass.failedInference()
select targetClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."