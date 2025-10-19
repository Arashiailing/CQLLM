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

// Retrieve the immediate left base class of a specified base in the inheritance hierarchy
ClassObject getLeftAdjacentBase(ClassObject targetClass, ClassObject baseClass) {
  // Find position index where baseClass appears in inheritance list (index > 0)
  // and return the base class at the preceding position (index - 1)
  exists(int positionIndex | 
    positionIndex > 0 and 
    targetClass.getBaseType(positionIndex) = baseClass and 
    result = targetClass.getBaseType(positionIndex - 1)
  )
}

// Query classes with invalid method resolution order
from ClassObject problematicClass, ClassObject leftBase, ClassObject rightBase
where 
  // Verify target class is new-style and has problematic inheritance structure
  problematicClass.isNewStyle() and
  leftBase = getLeftAdjacentBase(problematicClass, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()