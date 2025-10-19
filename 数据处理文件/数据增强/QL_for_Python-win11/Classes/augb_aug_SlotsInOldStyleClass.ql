/**
 * @name `__slots__` in old-style class
 * @description In Python, classes that don't inherit from object (old-style classes) have improper
 *              support for the `__slots__` attribute. When `__slots__` is defined in an old-style class,
 *              it doesn't replace the instance dictionary as intended, but instead creates a standard
 *              class attribute named `__slots__`. This can result in unexpected behavior and increased
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

from ClassObject clsWithSlotsIssue
where 
  // Identify old-style classes (those not inheriting from object)
  not clsWithSlotsIssue.isNewStyle() and 
  // Check if the problematic class declares __slots__
  clsWithSlotsIssue.declaresAttribute("__slots__") and 
  // Exclude classes where inference failed to avoid false positives
  not clsWithSlotsIssue.failedInference()
select clsWithSlotsIssue,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."