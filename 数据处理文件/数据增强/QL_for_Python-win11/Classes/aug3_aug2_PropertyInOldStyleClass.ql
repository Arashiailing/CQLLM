/**
 * @name Property in old-style class
 * @description Identifies property descriptors within old-style classes, which are unsupported
 *              in Python versions 2.1 and later. This can lead to unexpected behavior or runtime errors.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Find property descriptors defined within old-style classes
from PropertyObject propertyDescriptor, ClassObject enclosingClass
// Verify the following conditions:
where
  // The property must be declared as an attribute of the class
  enclosingClass.declaredAttribute(_) = propertyDescriptor and
  // Ensure the class inference was successful
  not enclosingClass.failedInference() and
  // Confirm the class is an old-style class (not inheriting from 'object')
  not enclosingClass.isNewStyle()
// Report the property descriptor with an informative message
select propertyDescriptor,
  "Property " + propertyDescriptor.getName() + " will not work properly, as class " + enclosingClass.getName() +
    " is an old-style class."