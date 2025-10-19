/**
 * @name `__slots__` in old-style class
 * @description Old-style Python classes (those not inheriting from object) do not properly support
 *              the `__slots__` attribute. When used in such classes, `__slots__` fails to override
 *              the class dictionary as intended, instead creating a regular class attribute named
 *              `__slots__`. This leads to unexpected behavior and memory inefficiency.
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
  // Verify class analysis completed successfully
  not oldStyleClass.failedInference() and
  // Confirm class is old-style (not inheriting from object)
  not oldStyleClass.isNewStyle() and 
  // Check for explicit __slots__ attribute declaration
  oldStyleClass.declaresAttribute("__slots__")
select oldStyleClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."