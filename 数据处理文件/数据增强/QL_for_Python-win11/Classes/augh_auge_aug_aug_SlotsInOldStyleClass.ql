/**
 * @name `__slots__` in old-style class
 * @description Finds legacy Python classes (non-new-style) that define `__slots__`. 
 *              In these cases, `__slots__` behaves like a regular attribute instead of 
 *              enabling memory optimization, leading to unexpected behavior and 
 *              performance issues.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject legacyClassDef
where 
  // Basic class validation
  not legacyClassDef.failedInference() 
  and 
  // Class type verification
  not legacyClassDef.isNewStyle() 
  and 
  // Attribute check
  legacyClassDef.declaresAttribute("__slots__") 
select legacyClassDef,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."