/**
 * @name Property in old-style class
 * @description Detects property descriptors defined in old-style classes, which lack proper support since Python 2.1.
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
from PropertyObject propertyObj, ClassObject enclosingClass
// Ensure the following conditions are met:
// 1. Property is directly declared in the class scope
// 2. Class type inference completed successfully
// 3. Class uses old-style inheritance (not inheriting from 'object')
where 
  enclosingClass.declaredAttribute(_) = propertyObj and
  not enclosingClass.failedInference() and
  not enclosingClass.isNewStyle()
// Generate warning message with property and class names
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + enclosingClass.getName() +
    " is an old-style class."