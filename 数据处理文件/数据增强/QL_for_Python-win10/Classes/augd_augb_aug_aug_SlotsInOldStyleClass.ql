/**
 * @name `__slots__` in old-style class
 * @description Detects classes that don't inherit from 'object' (old-style) 
 *              yet define `__slots__`. This causes `__slots__` to behave 
 *              as a regular class attribute instead of providing memory 
 *              optimization, leading to unintended behavior.
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
  // Ensure class analysis completed successfully
  not problematicClass.failedInference()
  and
  // Identify old-style classes (not inheriting from 'object')
  not problematicClass.isNewStyle()
  and
  // Check if class explicitly defines __slots__ attribute
  problematicClass.declaresAttribute("__slots__")
select problematicClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."