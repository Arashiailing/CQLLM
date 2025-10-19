/**
 * @name `__slots__` in old-style class
 * @description Declaring `__slots__` in old-style classes doesn't override the class dictionary 
 *              as intended, since this feature is unsupported. Instead, it merely creates 
 *              a regular class attribute named `__slots__`.
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
  // Identify old-style classes (non-new-style)
  not targetClass.isNewStyle()
  // Check for explicit `__slots__` declaration
  and targetClass.declaresAttribute("__slots__")
  // Ensure valid class inference
  and not targetClass.failedInference()
select targetClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."