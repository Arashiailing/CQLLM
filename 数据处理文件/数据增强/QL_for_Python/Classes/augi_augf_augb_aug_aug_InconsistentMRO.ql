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

// Detects MRO conflicts where a preceding base class improperly supersedes a following base class
// This violates Python's C3 linearization algorithm and causes runtime type errors
predicate mro_conflict_exists(ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase) {
  // Ensure new-style inheritance (mandatory for MRO analysis)
  targetClass.isNewStyle() and
  // Identify consecutive base classes in inheritance hierarchy
  exists(int index | 
    index > 0 and 
    targetClass.getBaseType(index) = laterBase and 
    earlierBase = targetClass.getBaseType(index - 1)
  ) and
  // Verify improper supertype relationship between bases
  earlierBase = laterBase.getAnImproperSuperType()
}

// Report classes with invalid MRO configurations causing runtime failures
from ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase
where mro_conflict_exists(targetClass, earlierBase, laterBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", earlierBase,
  earlierBase.getName(), laterBase, laterBase.getName()