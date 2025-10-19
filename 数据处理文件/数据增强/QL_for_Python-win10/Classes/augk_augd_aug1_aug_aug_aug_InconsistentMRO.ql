/**
 * @name Inconsistent method resolution order
 * @description Detects Python class definitions with inheritance hierarchies
 *              that cause method resolution order (MRO) conflicts leading to runtime type errors
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

/**
 * Identifies classes with inheritance hierarchies creating MRO conflicts.
 * This predicate detects when a class inherits from two classes where one
 * is an improper superclass of the other, causing potential runtime failures.
 */
predicate has_mro_conflict(ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase) {
  // Verify the class follows new-style inheritance rules
  targetClass.isNewStyle() and
  // Check consecutive base classes for problematic inheritance relationships
  exists(int basePosition | 
    // Ensure we're examining consecutive base classes
    basePosition > 0 and 
    laterBase = targetClass.getBaseType(basePosition) and 
    earlierBase = targetClass.getBaseType(basePosition - 1) and
    // Detect improper superclass relationship causing MRO conflict
    earlierBase = laterBase.getAnImproperSuperType()
  )
}

/**
 * Main query identifying classes with invalid MRO and providing diagnostic details.
 * Reports classes that cannot be constructed due to MRO conflicts between base classes.
 */
from ClassObject faultyClass, ClassObject baseA, ClassObject baseB
where has_mro_conflict(faultyClass, baseA, baseB)
select faultyClass,
  "Construction of class " + faultyClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()