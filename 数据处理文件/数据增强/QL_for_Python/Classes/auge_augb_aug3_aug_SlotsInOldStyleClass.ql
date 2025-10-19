/**
 * @name `__slots__` in old-style class
 * @description An old-style class (not inheriting from `object`) using `__slots__` 
 *              creates a regular class attribute instead of overriding the instance 
 *              dictionary mechanism. This negates memory optimization and causes 
 *              unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject legacyClass
where 
  not legacyClass.isNewStyle() 
  and legacyClass.declaresAttribute("__slots__") 
  and not legacyClass.failedInference()
select legacyClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."