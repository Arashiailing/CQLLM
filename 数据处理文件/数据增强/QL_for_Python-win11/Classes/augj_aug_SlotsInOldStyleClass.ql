/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (classes not inheriting from object) lack proper support
 *              for the `__slots__` attribute. When used in such classes, `__slots__` fails to override
 *              the class dictionary as intended, instead creating a regular class attribute named
 *              `__slots__`. This behavior leads to unexpected results and inefficient memory usage.
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
  not cls.isNewStyle() 
  and cls.declaresAttribute("__slots__") 
  and not cls.failedInference()
select cls,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."