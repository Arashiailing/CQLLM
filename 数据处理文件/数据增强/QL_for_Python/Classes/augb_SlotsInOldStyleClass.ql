/**
 * @name `__slots__` in old-style class
 * @description Declaring `__slots__` in old-style classes doesn't provide memory optimization
 *              as it only creates a regular class attribute instead of overriding the instance dictionary.
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