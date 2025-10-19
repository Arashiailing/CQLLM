/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (those not inheriting from object) do not properly support
 *              the `__slots__` attribute. When `__slots__` is used in an old-style class, it does not
 *              override the class dictionary as intended, but instead creates a regular class attribute
 *              named `__slots__`. This can lead to unexpected behavior and memory inefficiency.
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
  // Ensure class analysis completed successfully
  not cls.failedInference() and
  // Identify old-style classes (not inheriting from object)
  not cls.isNewStyle() and 
  // Check for explicit __slots__ declaration
  cls.declaresAttribute("__slots__")
select cls,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."