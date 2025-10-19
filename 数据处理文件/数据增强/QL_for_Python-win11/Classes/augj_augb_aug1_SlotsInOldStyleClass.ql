/**
 * @name Old-style class with `__slots__` declaration
 * @description Identifies old-style classes that define `__slots__`, which fails to override 
 *              the instance dictionary as intended and merely creates a regular class attribute.
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
  // Check if the class is old-style (not new-style)
  not legacyClass.isNewStyle() 
  // Verify that the class declares the __slots__ attribute
  and legacyClass.declaresAttribute("__slots__") 
  // Ensure the class inference did not fail
  and not legacyClass.failedInference()
select legacyClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."