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
from PropertyObject propertyDescriptor, ClassObject containerClass
where 
  // Condition 1: Property is explicitly declared in the class
  containerClass.declaredAttribute(_) = propertyDescriptor and
  // Condition 2: Class inference completed successfully
  not containerClass.failedInference() and
  // Condition 3: Class uses old-style inheritance (not new-style)
  not containerClass.isNewStyle()
// Select the problematic property with contextual warning message
select propertyDescriptor,
  "Property " + propertyDescriptor.getName() + " will not work properly, as class " + containerClass.getName() +
    " is an old-style class."