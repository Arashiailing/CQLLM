/**
 * @name Inconsistent method resolution order
 * @description Class definition will raise a type error at runtime due to inconsistent method resolution order (MRO)
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
 * Retrieves the immediate left neighbor of a specified base class in the inheritance hierarchy.
 * @param targetClass The class containing the base classes
 * @param specifiedBase The base class for which to find the left neighbor
 * @return The base class immediately to the left of the specified base
 */
ClassObject getImmediateLeftBase(ClassObject targetClass, ClassObject specifiedBase) {
  exists(int position | 
    position > 0 and 
    targetClass.getBaseType(position) = specifiedBase and 
    result = targetClass.getBaseType(position - 1)
  )
}

/**
 * Identifies classes with invalid method resolution order (MRO).
 * An MRO becomes invalid when a base class appears to the right of one of its own subclasses.
 * @param problematicClass The class exhibiting invalid MRO
 * @param superTypeBase The base class that should not be a supertype of the right base
 * @param subTypeBase The base class that should not be a subtype of the left base
 */
predicate exhibitsInvalidMRO(ClassObject problematicClass, ClassObject superTypeBase, ClassObject subTypeBase) {
  problematicClass.isNewStyle() and
  superTypeBase = getImmediateLeftBase(problematicClass, subTypeBase) and
  superTypeBase = subTypeBase.getAnImproperSuperType()
}

/**
 * Primary query detecting classes with inconsistent method resolution order.
 * These classes will trigger runtime type errors during instantiation.
 */
from ClassObject problematicClass, ClassObject superTypeBase, ClassObject subTypeBase
where exhibitsInvalidMRO(problematicClass, superTypeBase, subTypeBase)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order (MRO) for bases $@ and $@.", superTypeBase,
  superTypeBase.getName(), subTypeBase, subTypeBase.getName()