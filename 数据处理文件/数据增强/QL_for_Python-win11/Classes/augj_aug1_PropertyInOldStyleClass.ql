/**
 * @name Property in old-style class
 * @description Identifies property descriptors used in old-style classes,
 *              which are incompatible with Python 2.1+.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Find property descriptors and the classes they belong to
from PropertyObject prop, ClassObject cls
where
  // Property is defined as an attribute within the class
  cls.declaredAttribute(_) = prop
  // Class analysis completed without errors
  and not cls.failedInference()
  // Class is old-style (not derived from 'object')
  and not cls.isNewStyle()
// Report the problematic property and its containing class
select prop,
  "Property '" + prop.getName() + "' will not work properly, as class '" + 
  cls.getName() + "' is an old-style class."