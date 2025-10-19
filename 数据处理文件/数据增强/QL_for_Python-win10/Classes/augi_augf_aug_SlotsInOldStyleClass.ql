/**
 * @name `__slots__` in old-style class
 * @description Detects Python classes that do not inherit from object (old-style classes)
 *              yet define the `__slots__` attribute. In such cases, `__slots__` doesn't function
 *              as expected - rather than restricting instance attribute creation by overriding
 *              the class dictionary, it simply creates a standard class attribute named `__slots__`.
 *              This behavior is unexpected and eliminates the memory optimization advantages
 *              that `__slots__` offers in new-style classes.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject targetClass
where 
  // Confirm the class is old-style (does not inherit from object)
  not targetClass.isNewStyle() 
  // Check if the class defines the __slots__ attribute
  and targetClass.declaresAttribute("__slots__") 
  // Validate that class inference completed successfully
  and not targetClass.failedInference()
select targetClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."