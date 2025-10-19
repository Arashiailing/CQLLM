/**
 * @name Inconsistent method resolution order
 * @description Detects Python classes with inheritance hierarchies that cause MRO conflicts,
 *              potentially leading to runtime type errors during class construction
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
 * Identifies inheritance hierarchies with method resolution order conflicts.
 * This predicate finds classes inheriting from two classes where one is an improper
 * superclass of the other, creating potential runtime errors.
 */
predicate has_mro_conflict(ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase) {
  // Check if the class follows new-style inheritance rules
  targetClass.isNewStyle() and
  // Find consecutive base classes with problematic inheritance relationship
  exists(int basePosition | 
    // Validate we're examining consecutive base classes
    basePosition > 0 and 
    laterBase = targetClass.getBaseType(basePosition) and 
    earlierBase = targetClass.getBaseType(basePosition - 1) and
    // Identify improper superclass relationship causing MRO conflict
    earlierBase = laterBase.getAnImproperSuperType()
  )
}

/**
 * Primary query that identifies classes with invalid MRO and provides diagnostic details.
 * Reports classes that cannot be constructed due to MRO conflicts between their base classes.
 */
from ClassObject faultyClass, ClassObject initialBase, ClassObject subsequentBase
where has_mro_conflict(faultyClass, initialBase, subsequentBase)
select faultyClass,
  "Construction of class " + faultyClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", initialBase,
  initialBase.getName(), subsequentBase, subsequentBase.getName()