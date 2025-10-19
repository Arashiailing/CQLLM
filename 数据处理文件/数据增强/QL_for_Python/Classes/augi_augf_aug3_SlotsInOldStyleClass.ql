/**
 * @name `__slots__` in old-style class
 * @description Old-style Python classes (not inheriting from 'object') cannot utilize 
 *              the `__slots__` optimization. Defining `__slots__` in such classes 
 *              creates a regular attribute without memory benefits.
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
  // Exclude classes with inference failures
  not cls.failedInference() 
  // Identify non-new-style (old-style) classes
  and not cls.isNewStyle() 
  // Check presence of __slots__ attribute
  and cls.declaresAttribute("__slots__") 
select cls, 
  "Using '__slots__' in an old style class creates a regular attribute instead of enabling optimization."