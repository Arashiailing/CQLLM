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

// Detects classes with problematic MRO by analyzing inheritance relationships
// between consecutive base classes in the inheritance hierarchy
predicate has_mro_conflict(ClassObject target, ClassObject baseA, ClassObject baseB) {
  // Ensure the class is a new-style class (required for MRO analysis)
  target.isNewStyle() and
  // Find consecutive base classes in the inheritance list
  exists(int position | 
    position > 0 and 
    target.getBaseType(position) = baseB and 
    baseA = target.getBaseType(position - 1)
  ) and
  // Verify the first base is an improper supertype of the second base
  baseA = baseB.getAnImproperSuperType()
}

// Identify all classes with invalid MRO and generate diagnostic messages
from ClassObject cls, ClassObject precedingBase, ClassObject followingBase
where has_mro_conflict(cls, precedingBase, followingBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()