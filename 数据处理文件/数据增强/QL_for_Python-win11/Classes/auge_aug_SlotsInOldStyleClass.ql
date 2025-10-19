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

from ClassObject problematicClass
where 
  not problematicClass.failedInference() and
  not problematicClass.isNewStyle() and 
  problematicClass.declaresAttribute("__slots__")
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."