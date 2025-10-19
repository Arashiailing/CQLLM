/**
 * @name Property in old-style class
 * @description Detects property descriptors within old-style Python classes, which are not properly supported since Python 2.1.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

/**
 * This query identifies property objects defined within old-style classes.
 * Old-style classes in Python (pre-2.1) have limitations with property descriptors,
 * which can lead to unexpected behavior or runtime errors.
 */
from PropertyObject propertyDescriptor, ClassObject targetClass
where
  // Condition 1: The property is directly declared as an attribute of the class
  targetClass.declaredAttribute(_) = propertyDescriptor and
  // Condition 2: The class type inference was successful (no analysis failures)
  not targetClass.failedInference() and
  // Condition 3: The class uses old-style inheritance (not inheriting from 'object')
  not targetClass.isNewStyle()
// Report the problematic property with a contextual warning message
select propertyDescriptor,
  "Property '" + propertyDescriptor.getName() + "' will not function correctly, as class '" + 
  targetClass.getName() + "' uses old-style inheritance (not inheriting from 'object')."