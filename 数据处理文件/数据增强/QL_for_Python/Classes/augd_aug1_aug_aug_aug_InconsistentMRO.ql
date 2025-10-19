/**
 * @name Inconsistent method resolution order
 * @description Identifies Python class definitions that may lead to runtime type errors
 *              caused by inconsistent method resolution order (MRO) in inheritance hierarchies
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
 * Detects inheritance hierarchies that create method resolution order conflicts.
 * This predicate identifies when a class inherits from two classes where one
 * is an improper superclass of the other, leading to potential runtime errors.
 */
predicate has_mro_conflict(ClassObject analyzedClass, ClassObject precedingBase, ClassObject succeedingBase) {
  // Verify the class follows new-style inheritance rules
  analyzedClass.isNewStyle() and
  // Identify consecutive base classes with problematic inheritance relationship
  exists(int baseIndex | 
    // Ensure we're checking consecutive base classes
    baseIndex > 0 and 
    succeedingBase = analyzedClass.getBaseType(baseIndex) and 
    precedingBase = analyzedClass.getBaseType(baseIndex - 1) and
    // Detect improper superclass relationship causing MRO conflict
    precedingBase = succeedingBase.getAnImproperSuperType()
  )
}

/**
 * Main query identifying classes with invalid MRO and providing diagnostic information.
 * The query reports classes that cannot be constructed due to MRO conflicts between their base classes.
 */
from ClassObject problematicClass, ClassObject firstConflictingBase, ClassObject secondConflictingBase
where has_mro_conflict(problematicClass, firstConflictingBase, secondConflictingBase)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstConflictingBase,
  firstConflictingBase.getName(), secondConflictingBase, secondConflictingBase.getName()