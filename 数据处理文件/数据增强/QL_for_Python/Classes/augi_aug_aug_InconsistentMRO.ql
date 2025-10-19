/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions susceptible to runtime type errors caused by conflicting inheritance hierarchies with inconsistent method resolution order (MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes with MRO conflicts by analyzing base class relationships
predicate mro_conflict(ClassObject cls, ClassObject precedingBase, ClassObject followingBase) {
  // Verify target class uses new-style inheritance
  cls.isNewStyle() and
  // Locate consecutive base classes in inheritance hierarchy
  exists(int position | 
    position > 0 and 
    precedingBase = cls.getBaseType(position - 1) and 
    followingBase = cls.getBaseType(position)
  ) and
  // Confirm improper supertype relationship between consecutive bases
  precedingBase = followingBase.getAnImproperSuperType()
}

// Report classes with MRO conflicts and provide diagnostic details
from ClassObject cls, ClassObject precedingBase, ClassObject followingBase
where mro_conflict(cls, precedingBase, followingBase)
select cls,
  "Class " + cls.getName() +
    " construction may fail due to invalid method resolution order (MRO) between bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()