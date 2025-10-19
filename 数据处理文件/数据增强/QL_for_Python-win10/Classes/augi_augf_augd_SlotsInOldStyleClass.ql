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

from ClassObject nonNewStyleClass
where
  // Ensure class analysis is valid
  not nonNewStyleClass.failedInference()
  // Identify classes not inheriting from 'object'
  and not nonNewStyleClass.isNewStyle()
  // Check for explicit __slots__ declaration
  and nonNewStyleClass.declaresAttribute("__slots__")
select nonNewStyleClass, 
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."