/**
 * @name Property in old-style class
 * @description Detects usage of property descriptors in old-style classes, which is not supported
 *              in Python versions 2.1 and later. This can lead to unexpected behavior as properties
 *              in old-style classes do not function as intended.
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
// Check if the class declares the property and meets specific conditions
where 
  // The class must declare the property as one of its attributes
  classObj.declaredAttribute(_) = propertyObj and
  // The class should not have failed type inference
  not classObj.failedInference() and
  // The class must be an old-style class (not inheriting from 'object')
  not classObj.isNewStyle()
// Select the property object and generate an appropriate warning message
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + classObj.getName() +
    " is an old-style class."