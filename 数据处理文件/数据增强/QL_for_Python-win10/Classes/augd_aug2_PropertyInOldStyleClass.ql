/**
 * @name Property in old-style class
 * @description Identifies property descriptors within legacy Python classes (old-style),
 *              which lack proper support for properties since Python 2.1.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Find property descriptors that are incorrectly placed in old-style classes
from PropertyObject propDescriptor, ClassObject legacyClass
// Verify the following conditions:
// - The class contains the property as a declared attribute
// - The class analysis was successful (no inference failures)
// - The class follows old-style conventions (not inheriting from 'object')
where 
  // Condition 1: Property is defined as an attribute of the class
  legacyClass.declaredAttribute(_) = propDescriptor and
  // Condition 2: Class was properly analyzed without inference issues
  not legacyClass.failedInference() and
  // Condition 3: Class uses old-style definition (not new-style)
  not legacyClass.isNewStyle()
// Report the problematic property with a descriptive error message
select propDescriptor,
  "Property " + propDescriptor.getName() + " will not work properly, as class " + legacyClass.getName() +
    " is an old-style class."