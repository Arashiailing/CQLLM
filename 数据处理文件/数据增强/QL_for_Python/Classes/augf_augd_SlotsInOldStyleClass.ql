/**
 * @name `__slots__` in old-style class
 * @description Detects old-style classes declaring `__slots__`, which creates a regular 
 *              class attribute instead of overriding the class dictionary as intended.
 *              This feature is unsupported in old-style classes.
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
  // Validate class inference integrity
  not oldStyleClass.failedInference()
  // Identify non-new-style classes
  and not oldStyleClass.isNewStyle()
  // Check for explicit `__slots__` declaration
  and oldStyleClass.declaresAttribute("__slots__")
select oldStyleClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."