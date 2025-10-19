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

from ClassObject legacyClass
where 
  // Verify the class is not using new-style class inheritance
  not legacyClass.isNewStyle()
  // Confirm the class explicitly defines __slots__ attribute
  and legacyClass.declaresAttribute("__slots__")
  // Exclude classes where analysis failed to infer properties
  and not legacyClass.failedInference()
select legacyClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."