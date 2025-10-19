/**
 * @name `__slots__` in old-style class
 * @description In Python, declaring `__slots__` in old-style classes doesn't provide memory optimization
 *              because it merely creates a regular class attribute instead of overriding the instance dictionary.
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
  // Identify old-style classes that don't inherit from 'object'
  not cls.isNewStyle() and 
  // Check for explicit declaration of __slots__ attribute
  cls.declaresAttribute("__slots__") and 
  // Confirm successful class inference during analysis
  not cls.failedInference()
select cls, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."