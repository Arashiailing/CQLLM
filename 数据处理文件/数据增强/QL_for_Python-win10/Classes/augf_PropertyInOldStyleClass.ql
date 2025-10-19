/**
 * @name Property in old-style class
 * @description Detects property descriptors used in old-style classes which are incompatible
 *              with Python versions 2.1 and later. Properties in old-style classes do not
 *              function as expected due to lack of proper descriptor protocol support.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Identify property objects and their containing class objects
from PropertyObject propertyObj, ClassObject classObj
// Check if the class declares the property and meets the criteria for old-style class detection
where 
  // Verify the property is explicitly declared in the class
  classObj.declaredAttribute(_) = propertyObj and
  // Ensure the class inference was successful (no analysis failures)
  not classObj.failedInference() and
  // Confirm the class is not a new-style class (old-style classes don't support properties properly)
  not classObj.isNewStyle()
// Generate alert with property details and class context
select propertyObj,
  "Property '" + propertyObj.getName() + "' will not work correctly in class '" + classObj.getName() +
    "' because it is defined as an old-style class, which lacks proper property descriptor support."