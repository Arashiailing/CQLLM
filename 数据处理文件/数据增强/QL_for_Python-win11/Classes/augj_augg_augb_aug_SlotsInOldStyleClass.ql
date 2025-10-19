/**
 * @name `__slots__` in old-style class
 * @description Old-style Python classes (not inheriting from object) incorrectly handle `__slots__`.
 *              Instead of replacing the instance dictionary, this creates a standard class attribute,
 *              causing unexpected behavior and increased memory usage.
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
  // Check if class declares __slots__ attribute
  cls.declaresAttribute("__slots__")
  // Verify it's an old-style class (no object inheritance)
  and not cls.isNewStyle()
  // Exclude classes with failed inference to avoid false positives
  and not cls.failedInference()
select cls,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."