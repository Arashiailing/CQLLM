/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions that will cause runtime type errors due to invalid method resolution order (MRO)
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
 * Obtains the immediate left neighbor of a specified base class in a class's inheritance hierarchy.
 * @param targetClass The class containing the base classes
 * @param targetBase The base class for which to find the left neighbor
 * @return The base class directly preceding the specified base in the inheritance list
 */
ClassObject getLeftBase(ClassObject targetClass, ClassObject targetBase) {
  exists(int position | 
    position > 0 and 
    targetClass.getBaseType(position) = targetBase and 
    result = targetClass.getBaseType(position - 1)
  )
}

/**
 * Identifies classes with invalid method resolution order (MRO).
 * MRO becomes invalid when a base class appears to the right of one of its own subclasses.
 * @param targetClass The class being analyzed for MRO issues
 * @param leftSuperclass The base class that should not be a supertype of rightSuperclass
 * @param rightSuperclass The base class that should not be a subtype of leftSuperclass
 */
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftSuperclass, ClassObject rightSuperclass) {
  targetClass.isNewStyle() and
  leftSuperclass = getLeftBase(targetClass, rightSuperclass) and
  leftSuperclass = rightSuperclass.getAnImproperSuperType()
}

/**
 * Main query that detects classes with inconsistent method resolution order.
 * These problematic classes will trigger runtime type errors during instantiation.
 */
from ClassObject targetClass, ClassObject leftSuperclass, ClassObject rightSuperclass
where hasInvalidMRO(targetClass, leftSuperclass, rightSuperclass)
select targetClass,
  "Instantiation of class " + targetClass.getName() +
    " may fail due to invalid method resolution order (MRO) between base classes $@ and $@.", 
  leftSuperclass, leftSuperclass.getName(), 
  rightSuperclass, rightSuperclass.getName()