/**
 * @name Inconsistent method resolution order
 * @description Identifies classes prone to runtime failures caused by conflicting method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Detects inheritance hierarchies where adjacent base classes create MRO conflicts
predicate mro_conflict_exists(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Ensure target class uses new-style inheritance
  targetClass.isNewStyle() and
  // Find consecutive base classes in inheritance declaration
  exists(int position | 
    position > 0 and 
    secondBase = targetClass.getBaseType(position) and 
    firstBase = targetClass.getBaseType(position - 1)
  ) and
  // Validate problematic superclass relationship between adjacent bases
  firstBase = secondBase.getAnImproperSuperType()
}

// Query classes with MRO conflicts and generate diagnostic messages
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where mro_conflict_exists(targetClass, firstBase, secondBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()