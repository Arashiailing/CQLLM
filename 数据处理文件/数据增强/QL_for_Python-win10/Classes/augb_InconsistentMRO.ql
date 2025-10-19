/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions that will raise a type error at runtime due to inconsistent method resolution order (MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Helper predicate to identify invalid MRO scenarios
predicate has_invalid_mro(ClassObject cls, ClassObject leftBase, ClassObject rightBase) {
  // Check if class is new-style and has problematic base class ordering
  cls.isNewStyle() and
  exists(int index | 
    index > 0 and 
    cls.getBaseType(index) = rightBase and 
    leftBase = cls.getBaseType(index - 1)
  ) and
  // Verify leftBase is an improper super type of rightBase
  leftBase = rightBase.getAnImproperSuperType()
}

// Identify classes with invalid MRO and generate diagnostic messages
from ClassObject cls, ClassObject leftBase, ClassObject rightBase
where has_invalid_mro(cls, leftBase, rightBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()