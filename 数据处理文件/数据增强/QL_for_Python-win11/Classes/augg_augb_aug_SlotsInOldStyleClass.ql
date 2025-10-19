/**
 * @name `__slots__` in old-style class
 * @description In Python, old-style classes (those not inheriting from object) have improper
 *              support for the `__slots__` attribute. Defining `__slots__` in such a class
 *              does not replace the instance dictionary as intended; instead, it creates a standard
 *              class attribute named `__slots__`. This leads to unexpected behavior and increased
 *              memory usage.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject oldStyleClassWithSlots
where 
  // Verify the class declares __slots__ attribute
  oldStyleClassWithSlots.declaresAttribute("__slots__") and
  // Confirm it's an old-style class (not inheriting from object)
  not oldStyleClassWithSlots.isNewStyle() and
  // Exclude classes with failed inference to prevent false positives
  not oldStyleClassWithSlots.failedInference()
select oldStyleClassWithSlots,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."