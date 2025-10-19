/**
 * @name Inconsistent method resolution order
 * @description Class definition will raise a type error at runtime due to inconsistent method resolution order(MRO)
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
 * Retrieves the immediate left base class of a specified base within a class hierarchy.
 * @param cls The class containing the base classes
 * @param baseClass The base class for which to find the left neighbor
 * @return The base class immediately to the left of the specified base
 */
ClassObject getLeftBase(ClassObject cls, ClassObject baseClass) {
  exists(int index | 
    index > 0 and 
    cls.getBaseType(index) = baseClass and 
    result = cls.getBaseType(index - 1)
  )
}

/**
 * Determines if a class has an invalid method resolution order (MRO).
 * An MRO is invalid when a base class appears to the right of one of its subclasses.
 * @param cls The class to check for invalid MRO
 * @param leftBase The base class that should not be a super type of rightBase
 * @param rightBase The base class that should not be a sub type of leftBase
 */
predicate hasInvalidMRO(ClassObject cls, ClassObject leftBase, ClassObject rightBase) {
  cls.isNewStyle() and
  leftBase = getLeftBase(cls, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
}

/**
 * Main query that identifies classes with inconsistent method resolution order.
 * These classes will raise type errors at runtime during construction.
 */
from ClassObject cls, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(cls, leftBase, rightBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()