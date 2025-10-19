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

// Identify property objects that are problematic due to being defined in old-style classes
from PropertyObject propertyObj, ClassObject hostClass
where
  // First, ensure the property is properly defined within the class
  exists(string attrName | hostClass.declaredAttribute(attrName) = propertyObj) and
  // Second, verify the class inference was successful
  not hostClass.failedInference() and
  // Finally, confirm the class is an old-style class (not inheriting from 'object')
  not hostClass.isNewStyle()
// Output the problematic property with a descriptive error message
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + hostClass.getName() +
    " is an old-style class."