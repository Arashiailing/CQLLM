/**
 * @name Method Resolution Order Inconsistency
 * @description Detects classes with inheritance hierarchies that lead to runtime errors due to invalid method resolution order (MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies MRO conflicts through analysis of inheritance relationships between adjacent base classes
predicate has_mro_conflict(ClassObject targetCls, ClassObject precedingBase, ClassObject followingBase) {
  // Ensure we only analyze new-style classes which support proper MRO
  targetCls.isNewStyle() and
  // Confirm problematic inheritance: precedingBase is an improper supertype of followingBase
  precedingBase = followingBase.getAnImproperSuperType() and
  // Check for consecutive base classes in inheritance hierarchy
  exists(int idx | 
    idx > 0 and 
    targetCls.getBaseType(idx) = followingBase and 
    precedingBase = targetCls.getBaseType(idx - 1)
  )
}

// Identify classes with invalid MRO and generate diagnostic messages
from ClassObject problematicCls, ClassObject firstBase, ClassObject secondBase
where has_mro_conflict(problematicCls, firstBase, secondBase)
select problematicCls,
  "Class " + problematicCls.getName() +
    " construction may fail due to invalid method resolution order (MRO) between base classes $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()