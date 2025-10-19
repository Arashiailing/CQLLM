/**
 * @name `__slots__` in old-style class
 * @description In Python, classes that don't inherit from `object` (old-style classes) 
 *              don't correctly implement the `__slots__` feature. When used in such classes,
 *              `__slots__` behaves like a regular class attribute rather than optimizing 
 *              memory usage by replacing the instance dictionary. This leads to both 
 *              unexpected behavior and inefficient memory utilization.
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
  // Check if the class is old-style (not inheriting from object)
  not targetClass.isNewStyle()
  // Verify that the class declares __slots__ attribute
  and targetClass.declaresAttribute("__slots__")
  // Ensure the class analysis was successful
  and not targetClass.failedInference()
select targetClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."