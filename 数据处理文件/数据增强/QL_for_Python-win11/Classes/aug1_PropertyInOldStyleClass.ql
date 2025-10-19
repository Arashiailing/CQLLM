/**
 * @name Property in old-style class
 * @description Detects usage of property descriptors in old-style classes,
 *              which is not supported in Python 2.1 and later versions.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Identify property objects and their containing classes
from PropertyObject propertyObj, ClassObject classObj
// Check if the class declares the property and meets old-style class criteria
where 
  // The property must be declared as an attribute of the class
  classObj.declaredAttribute(_) = propertyObj and
  // Ensure the class inference was successful (no analysis failures)
  not classObj.failedInference() and
  // Verify the class is an old-style class (not inheriting from 'object')
  not classObj.isNewStyle()
// Generate alert with property name and affected class information
select propertyObj,
  "Property '" + propertyObj.getName() + "' will not work properly, as class '" + 
  classObj.getName() + "' is an old-style class."