/**
 * @name Property in old-style class
 * @description Finds property descriptors used in old-style classes, which are incompatible from Python 2.1 onwards.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// Locate property descriptors that cause compatibility issues when used in legacy class definitions
from PropertyObject propertyDescriptor, ClassObject legacyClass
// Check the following criteria:
// 1. The class follows the legacy pattern (not inheriting from 'object' or built-in types)
// 2. The class type inference succeeded (ensuring analysis accuracy)
// 3. The property is defined as an explicit attribute within the class scope
where 
  not legacyClass.isNewStyle() and
  not legacyClass.failedInference() and
  propertyDescriptor = legacyClass.declaredAttribute(_)
// Report the finding with a detailed explanation about the compatibility problem
select propertyDescriptor,
  "Property '" + propertyDescriptor.getName() + "' is incompatible with class '" + 
  legacyClass.getName() + "' because it is defined as an old-style class. " +
  "Property descriptors require new-style classes to function correctly."