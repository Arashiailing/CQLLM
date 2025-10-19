/**
 * @name Property in old-style class
 * @description Detects property descriptors inside old-style classes, which are not supported
 *              in Python 2.1 and later. This may cause unexpected behavior or runtime errors.
 * @kind problem
 * @id py/property-in-old-style-class
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 */

import python

// Identify property descriptors located within old-style classes
from PropertyObject propertyObj, ClassObject hostClass
// Check the following criteria:
where
  // The property must be an attribute of the class
  hostClass.declaredAttribute(_) = propertyObj and
  // The class must be successfully inferred
  not hostClass.failedInference() and
  // The class must be an old-style class (not derived from 'object')
  not hostClass.isNewStyle()
// Report the property descriptor with a detailed message
select propertyObj,
  "Property " + propertyObj.getName() + " will not function correctly, as class " + hostClass.getName() +
    " is an old-style class."