/**
 * @name `__slots__` in old-style class
 * @description Identifies old-style classes declaring `__slots__`, which fails to override 
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

from ClassObject oldStyleClass
where 
  // Ensure the class is an old-style class (not inheriting from object)
  not oldStyleClass.isNewStyle() 
  // Check if the class explicitly declares __slots__ attribute
  and oldStyleClass.declaresAttribute("__slots__") 
  // Exclude classes with failed type inference to avoid false positives
  and not oldStyleClass.failedInference()
select oldStyleClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."