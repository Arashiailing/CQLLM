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
 * Detects classes with inheritance hierarchies that create MRO conflicts.
 * This predicate identifies when a class inherits from two classes where one
 * is an improper superclass of the other, leading to potential runtime errors.
 */
predicate has_mro_conflict(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Ensure the class follows new-style inheritance rules
  targetClass.isNewStyle() and
  // Find consecutive base classes in the inheritance declaration and validate their relationship
  exists(int basePosition | 
    basePosition > 0 and 
    secondBase = targetClass.getBaseType(basePosition) and 
    firstBase = targetClass.getBaseType(basePosition - 1) and
    firstBase = secondBase.getAnImproperSuperType()
  )
}

/**
 * Main query that identifies classes with invalid MRO and provides diagnostic information.
 * The query reports classes that cannot be constructed due to MRO conflicts between their base classes.
 */
from ClassObject problematicClass, ClassObject conflictingBase1, ClassObject conflictingBase2
where has_mro_conflict(problematicClass, conflictingBase1, conflictingBase2)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", conflictingBase1,
  conflictingBase1.getName(), conflictingBase2, conflictingBase2.getName()