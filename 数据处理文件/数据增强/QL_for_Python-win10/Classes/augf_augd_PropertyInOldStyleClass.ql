/**
 * @name Property in old-style class
 * @description Detects property descriptors defined within old-style classes, which are incompatible 
 *              with Python versions 2.1 and later. Properties in old-style classes do not function 
 *              as expected due to implementation differences in the Python object model.
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
from PropertyObject prop, ClassObject cls
where
  // Verify the class successfully declared this property
  cls.declaredAttribute(_) = prop and
  // Ensure the class inference was successful (no analysis failures)
  not cls.failedInference() and
  // Confirm the class uses old-style semantics (not inheriting from 'object')
  not cls.isNewStyle()
// Generate alert with details about the incompatible property usage
select prop,
  "Property '" + prop.getName() + "' in class '" + cls.getName() +
    "' will not function correctly because old-style classes do not support property descriptors."