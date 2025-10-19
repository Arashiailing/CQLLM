/**
 * @name `__slots__` in old-style class
 * @description Old-style classes (not inheriting from `object`) do not properly support `__slots__`.
 *              Using `__slots__` creates a regular class attribute instead of overriding the instance dictionary,
 *              leading to unexpected behavior and memory inefficiency.
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