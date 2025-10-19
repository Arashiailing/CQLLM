/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (those not inheriting from object) do not properly support
 *              the `__slots__` attribute. When `__slots__` is used in an old-style class, it simply
 *              creates a regular class attribute named `__slots__` instead of restricting instance
 *              attributes as intended.
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
  // Identify old-style classes (not inheriting from object)
  not cls.isNewStyle()
  // Verify that the class declares the __slots__ attribute
  and cls.declaresAttribute("__slots__")
  // Ensure that the class inference did not fail
  and not cls.failedInference()
select cls, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."