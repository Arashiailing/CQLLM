/**
 * @name Property in old-style class
 * @description Detects property descriptors within legacy Python classes that lack proper support since version 2.1.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Identify legacy classes containing property descriptors
from PropertyObject propDescriptor, ClassObject enclosingClass
where 
  // Verify class is properly analyzable and contains the property
  enclosingClass.declaredAttribute(_) = propDescriptor and
  not enclosingClass.failedInference() and
  
  // Confirm class uses legacy inheritance model (non-new-style)
  not enclosingClass.isNewStyle()

// Generate warning message with property and class context
select propDescriptor,
  "Property '" + propDescriptor.getName() + "' will malfunction because class '" + enclosingClass.getName() +
    "' uses legacy inheritance (old-style class)."