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

// Identify property descriptors that are problematic when used in legacy class definitions
from PropertyObject propertyDescriptor, ClassObject legacyClass
// Validate the following conditions:
// 1. The property is explicitly declared as an attribute within the class
// 2. The class type inference completed successfully (ensuring accurate analysis)
// 3. The class follows the old-style pattern (not inheriting from 'object' or built-in types)
where 
  legacyClass.declaredAttribute(_) = propertyDescriptor and
  not legacyClass.failedInference() and
  not legacyClass.isNewStyle()
// Generate alert with detailed explanation about the compatibility issue
select propertyDescriptor,
  "Property '" + propertyDescriptor.getName() + "' is incompatible with class '" + 
  legacyClass.getName() + "' because it is defined as an old-style class. " +
  "Property descriptors require new-style classes to function correctly."