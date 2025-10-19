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

// Identify property descriptors that are problematic when used in legacy class definitions
from PropertyObject prop, ClassObject oldStyleClass
// Validate the following conditions:
// 1. The property is explicitly declared as an attribute within the class
// 2. The class type inference completed successfully (ensuring accurate analysis)
// 3. The class follows the old-style pattern (not inheriting from 'object' or built-in types)
where 
  prop = oldStyleClass.declaredAttribute(_) and
  not oldStyleClass.failedInference() and
  not oldStyleClass.isNewStyle()
// Generate alert with detailed explanation about the compatibility issue
select prop,
  "Property '" + prop.getName() + "' is incompatible with class '" + 
  oldStyleClass.getName() + "' because it is defined as an old-style class. " +
  "Property descriptors require new-style classes to function correctly."