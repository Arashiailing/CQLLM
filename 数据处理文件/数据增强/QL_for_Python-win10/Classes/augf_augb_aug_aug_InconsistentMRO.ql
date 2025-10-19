/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions that are prone to runtime type errors caused by an inconsistent method resolution order (MRO) in their inheritance hierarchy
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Analyzes inheritance hierarchies to detect MRO conflicts between consecutive base classes
// Conflicts occur when a preceding base class is an improper supertype of a following base class
predicate has_mro_conflict(ClassObject cls, ClassObject precedingBase, ClassObject followingBase) {
  // Verify the class uses new-style inheritance (required for MRO analysis)
  cls.isNewStyle() and
  // Locate consecutive base classes in the inheritance list
  exists(int position | 
    position > 0 and 
    cls.getBaseType(position) = followingBase and 
    precedingBase = cls.getBaseType(position - 1)
  ) and
  // Confirm the preceding base is an improper supertype of the following base
  precedingBase = followingBase.getAnImproperSuperType()
}

// Report classes with invalid MRO configurations
from ClassObject cls, ClassObject precedingBase, ClassObject followingBase
where has_mro_conflict(cls, precedingBase, followingBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()