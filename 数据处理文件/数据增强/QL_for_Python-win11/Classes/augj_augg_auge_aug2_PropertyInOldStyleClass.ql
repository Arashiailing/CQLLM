/**
 * @name Property in old-style class
 * @description Detects property descriptors used within legacy class definitions that are incompatible with Python 2.1+.
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
from PropertyObject propertyObj, ClassObject legacyClass
// The following conditions must be satisfied:
// - The property is explicitly declared as an attribute within the class
// - The class type inference completed successfully (ensuring accurate analysis)
// - The class follows the legacy pattern (not inheriting from 'object' or built-in types)
where 
  propertyObj = legacyClass.declaredAttribute(_) and
  not legacyClass.failedInference() and
  not legacyClass.isNewStyle()
// Generate alert with detailed explanation about the compatibility issue
select propertyObj,
  "Property '" + propertyObj.getName() + "' is incompatible with class '" + 
  legacyClass.getName() + "' because it is defined as an old-style class. " +
  "Property descriptors require new-style classes to function correctly."