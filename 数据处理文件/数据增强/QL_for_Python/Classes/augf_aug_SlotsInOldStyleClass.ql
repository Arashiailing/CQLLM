/**
 * @name `__slots__` in old-style class
 * @description This query identifies old-style Python classes (classes not inheriting from object)
 *              that declare the `__slots__` attribute. In old-style classes, `__slots__` does not
 *              behave as intended - instead of overriding the class dictionary to restrict instance
 *              attribute creation, it merely creates a regular class attribute named `__slots__`.
 *              This leads to unexpected behavior and negates the memory efficiency benefits
 *              that `__slots__` provides in new-style classes.
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
  // Check if the class is an old-style class (not inheriting from object)
  not cls.isNewStyle() 
  // Verify that the class declares the __slots__ attribute
  and cls.declaresAttribute("__slots__") 
  // Ensure the class inference was successful
  and not cls.failedInference()
select cls,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."