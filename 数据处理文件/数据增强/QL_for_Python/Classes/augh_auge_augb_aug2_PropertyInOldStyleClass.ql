/**
 * @name Property in old-style class
 * @description Identifies property descriptors in old-style classes that lack proper support since Python 2.1
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Find property objects defined within old-style classes
from PropertyObject propertyDescriptor, ClassObject oldStyleClass
// Verify three critical conditions:
// 1. Property is directly declared in the class scope
// 2. Class type inference completed successfully
// 3. Class uses old-style inheritance (doesn't inherit from 'object')
where 
  oldStyleClass.declaredAttribute(_) = propertyDescriptor and
  not oldStyleClass.failedInference() and
  not oldStyleClass.isNewStyle()
// Generate warning with property and class names
select propertyDescriptor,
  "Property " + propertyDescriptor.getName() + " will not work properly, as class " + 
  oldStyleClass.getName() + " is an old-style class."