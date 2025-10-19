/**
 * @name Inconsistent method resolution order
 * @description Class definition will raise a type error at runtime due to inconsistent method resolution order(MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Retrieve the immediate left base class of a specified base in inheritance hierarchy
ClassObject getImmediateLeftBase(ClassObject cls, ClassObject base) {
  // Find position index where base appears in inheritance list (index > 0)
  // and return the base class at preceding position (index - 1)
  exists(int idx | 
    idx > 0 and 
    cls.getBaseType(idx) = base and 
    result = cls.getBaseType(idx - 1)
  )
}

// Query classes with invalid method resolution order
from ClassObject problematicCls, ClassObject leftBase, ClassObject rightBase
where 
  // Verify target class is new-style and has problematic inheritance structure
  problematicCls.isNewStyle() and
  leftBase = getImmediateLeftBase(problematicCls, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
select problematicCls,
  "Construction of class " + problematicCls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()