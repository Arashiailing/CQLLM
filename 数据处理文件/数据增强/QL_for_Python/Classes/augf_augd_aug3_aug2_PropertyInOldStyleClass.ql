/**
 * @name Property in old-style class
 * @description Identifies property descriptors within old-style classes, which lack 
 *              proper support in Python 2.1+. This can lead to runtime errors or 
 *              unexpected behavior due to missing new-style class features.
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
from PropertyObject propertyDescriptor, ClassObject oldStyleClass
// Validate the following conditions:
where
  // The property must be a declared attribute of the class
  oldStyleClass.declaredAttribute(_) = propertyDescriptor and
  // Ensure the class definition was successfully analyzed
  not oldStyleClass.failedInference() and
  // Verify the class uses old-style inheritance (not derived from 'object')
  not oldStyleClass.isNewStyle()
// Report the problematic property with contextual information
select propertyDescriptor,
  "Property '" + propertyDescriptor.getName() + "' will malfunction because class '" + 
  oldStyleClass.getName() + "' uses old-style inheritance."