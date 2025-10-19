/**
 * @name Property in old-style class
 * @description Detects property descriptors used in old-style classes, which are not supported from Python 2.1 onward.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Identify property objects defined within old-style classes
from PropertyObject propertyObj, ClassObject targetClass
// Check conditions where:
// 1. The class declares the property
// 2. The class inference is successful
// 3. The class is an old-style class (not new-style)
where 
  targetClass.declaredAttribute(_) = propertyObj and
  not targetClass.failedInference() and
  not targetClass.isNewStyle()
// Select the property object and generate appropriate warning message
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + targetClass.getName() +
    " is an old-style class."