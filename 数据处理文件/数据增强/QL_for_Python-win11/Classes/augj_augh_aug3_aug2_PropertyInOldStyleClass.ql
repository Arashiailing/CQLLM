/**
 * @name Property in old-style class
 * @description Detects property descriptors defined within old-style classes, which are unsupported
 *              in Python 2.1+. This can cause runtime errors or unexpected behavior.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Identify problematic properties in old-style classes
from PropertyObject prop, ClassObject cls
where
  // Verify property is declared in the class
  cls.declaredAttribute(prop.getName()) = prop and
  // Ensure class inference succeeded
  not cls.failedInference() and
  // Confirm class is old-style (doesn't inherit from 'object')
  not cls.isNewStyle()
// Output property with error message
select prop,
  "Property " + prop.getName() + " will not work properly, as class " + cls.getName() +
    " is an old-style class."