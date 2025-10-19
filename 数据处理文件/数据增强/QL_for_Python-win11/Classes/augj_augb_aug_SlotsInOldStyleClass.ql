/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (not inheriting from object) incorrectly handle
 *              the `__slots__` attribute. Instead of replacing instance dictionaries as intended,
 *              it creates a regular class attribute named `__slots__`, leading to unexpected
 *              behavior and increased memory consumption.
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
  // Identify old-style classes that don't inherit from object
  not problematicClass.isNewStyle() 
  // Check for presence of __slots__ attribute
  and problematicClass.declaresAttribute("__slots__") 
  // Exclude classes with inference failures to prevent false positives
  and not problematicClass.failedInference()
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."