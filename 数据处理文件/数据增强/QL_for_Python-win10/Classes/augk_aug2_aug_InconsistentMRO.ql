/**
 * @name Inconsistent method resolution order
 * @description A class definition will raise a TypeError at runtime due to an inconsistent method resolution order (MRO). This occurs when a base class appears after one of its subclasses in the inheritance list.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identify classes with invalid inheritance structure causing MRO conflicts
from ClassObject targetClass, ClassObject precedingBase, ClassObject succeedingBase
where 
  // Ensure target class is new-style and has problematic inheritance
  targetClass.isNewStyle() and
  // Verify adjacent base classes in inheritance hierarchy
  exists(int basePosition | 
    basePosition > 0 and 
    targetClass.getBaseType(basePosition) = succeedingBase and 
    precedingBase = targetClass.getBaseType(basePosition - 1)
  ) and
  // Detect improper inheritance relationship between bases
  precedingBase = succeedingBase.getAnImproperSuperType()
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), succeedingBase, succeedingBase.getName()