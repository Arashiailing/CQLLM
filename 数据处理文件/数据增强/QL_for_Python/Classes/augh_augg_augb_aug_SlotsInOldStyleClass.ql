/**
 * @name `__slots__` in old-style class
 * @description Old-style classes (not inheriting from object) incorrectly handle `__slots__`.
 *              Instead of replacing the instance dictionary, it creates a standard class attribute,
 *              leading to unexpected behavior and increased memory usage.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject problemClass
where 
  // Check if class explicitly defines __slots__ attribute
  problemClass.declaresAttribute("__slots__") and
  // Verify class is old-style (not inheriting from object)
  not problemClass.isNewStyle() and
  // Exclude classes with failed type inference to avoid false positives
  not problemClass.failedInference()
select problemClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."