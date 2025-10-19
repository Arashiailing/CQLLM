/**
 * @name `__slots__` in old-style class
 * @description Detects old-style classes that declare `__slots__`, which doesn't override 
 *              the class dictionary as intended and instead creates a regular class attribute.
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
  not cls.isNewStyle() and 
  cls.declaresAttribute("__slots__") and 
  not cls.failedInference()
select cls, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."