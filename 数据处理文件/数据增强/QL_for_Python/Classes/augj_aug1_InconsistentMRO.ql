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
 * Retrieves the immediate predecessor base class in a class's inheritance hierarchy.
 * @param containerClass The class containing the base classes
 * @param targetBase The base class for which to find the predecessor
 * @return The base class immediately preceding the specified base
 */
ClassObject getPredecessorBase(ClassObject containerClass, ClassObject targetBase) {
  exists(int index | 
    index > 0 and 
    containerClass.getBaseType(index) = targetBase and 
    result = containerClass.getBaseType(index - 1)
  )
}

/**
 * Identifies classes with invalid method resolution order (MRO).
 * An MRO becomes invalid when a base class appears after its own subclass in the inheritance list.
 * @param targetClass The class being analyzed for MRO issues
 * @param leftBaseClass The base class that should not be a super type of rightBaseClass
 * @param rightBaseClass The base class that should not be a sub type of leftBaseClass
 */
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftBaseClass, ClassObject rightBaseClass) {
  targetClass.isNewStyle() and
  leftBaseClass = getPredecessorBase(targetClass, rightBaseClass) and
  leftBaseClass = rightBaseClass.getAnImproperSuperType()
}

/**
 * Main query that identifies classes with inconsistent method resolution order.
 * These classes will raise type errors at runtime during construction.
 */
from ClassObject targetClass, ClassObject leftBaseClass, ClassObject rightBaseClass
where hasInvalidMRO(targetClass, leftBaseClass, rightBaseClass)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBaseClass,
  leftBaseClass.getName(), rightBaseClass, rightBaseClass.getName()