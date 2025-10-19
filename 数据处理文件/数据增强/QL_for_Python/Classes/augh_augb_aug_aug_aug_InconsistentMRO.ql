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

// Identifies classes with problematic inheritance patterns where adjacent base classes create MRO conflicts
predicate hasMROConflict(ClassObject problematicClass, ClassObject baseA, ClassObject baseB) {
  // Verify the class uses new-style inheritance (required for MRO computation)
  problematicClass.isNewStyle() and
  // Locate consecutive base classes in the inheritance declaration
  exists(int basePosition | 
    basePosition > 0 and 
    baseB = problematicClass.getBaseType(basePosition) and 
    baseA = problematicClass.getBaseType(basePosition - 1)
  ) and
  // Detect problematic superclass relationship between adjacent bases
  baseA = baseB.getAnImproperSuperType()
}

// Query classes exhibiting MRO conflicts and generate diagnostic messages
from ClassObject problematicClass, ClassObject baseA, ClassObject baseB
where hasMROConflict(problematicClass, baseA, baseB)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()