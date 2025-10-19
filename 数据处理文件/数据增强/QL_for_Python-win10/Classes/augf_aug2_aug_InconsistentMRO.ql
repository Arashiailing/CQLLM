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

// Extract the directly preceding base class of a specified base within the inheritance chain
ClassObject fetchPrecedingBase(ClassObject sourceClass, ClassObject targetBase) {
  // Locate the index position where targetBase exists in the inheritance list (index must be > 0)
  // and return the base class at the prior position (index - 1)
  exists(int baseIndex | 
    baseIndex > 0 and 
    sourceClass.getBaseType(baseIndex) = targetBase and 
    result = sourceClass.getBaseType(baseIndex - 1)
  )
}

// Detect classes with problematic method resolution order
from ClassObject defectiveClass, ClassObject priorBase, ClassObject subsequentBase
where 
  // Ensure the examined class is new-style and exhibits inheritance issues
  defectiveClass.isNewStyle() and
  priorBase = fetchPrecedingBase(defectiveClass, subsequentBase) and
  priorBase = subsequentBase.getAnImproperSuperType()
select defectiveClass,
  "Construction of class " + defectiveClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", priorBase,
  priorBase.getName(), subsequentBase, subsequentBase.getName()