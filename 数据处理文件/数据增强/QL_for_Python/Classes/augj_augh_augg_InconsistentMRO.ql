/**
 * @name Inconsistent Method Resolution Order
 * @description A class definition may cause a runtime type error because of an inconsistent method resolution order (MRO).
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
 * Identifies classes with invalid method resolution order (MRO) where a base class appears 
 * both as an immediate left neighbor and as an improper supertype of another base class.
 * @param cls - The class being analyzed for MRO issues
 * @param leftNeighbor - The base class immediately to the left in inheritance hierarchy
 * @param rightNeighbor - The base class immediately to the right in inheritance hierarchy
 */
predicate hasInvalidMRO(ClassObject cls, ClassObject leftNeighbor, ClassObject rightNeighbor) {
  cls.isNewStyle() and
  exists(int inheritancePosition |
    inheritancePosition > 0 and
    cls.getBaseType(inheritancePosition) = rightNeighbor and
    leftNeighbor = cls.getBaseType(inheritancePosition - 1) and
    leftNeighbor = rightNeighbor.getAnImproperSuperType()
  )
}

// Generate alerts for classes with problematic inheritance structures
from ClassObject problematicClass, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(problematicClass, leftBase, rightBase)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()