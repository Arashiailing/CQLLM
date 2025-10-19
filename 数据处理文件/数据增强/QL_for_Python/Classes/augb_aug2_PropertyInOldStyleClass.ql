/**
 * @name Property in old-style class
 * @description Identifies property descriptors used in old-style classes, which lack proper support since Python 2.1.
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
from PropertyObject prop, ClassObject cls
// Verify the following conditions:
// 1. Property is directly declared in the class
// 2. Class type inference was successful
// 3. Class uses old-style inheritance (not new-style)
where 
  cls.declaredAttribute(_) = prop and
  not cls.failedInference() and
  not cls.isNewStyle()
// Report the property with contextual warning message
select prop,
  "Property " + prop.getName() + " will not work properly, as class " + cls.getName() +
    " is an old-style class."