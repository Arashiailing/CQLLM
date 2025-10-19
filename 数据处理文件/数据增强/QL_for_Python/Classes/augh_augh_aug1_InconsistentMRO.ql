/**
 * @name Inconsistent method resolution order
 * @description Detects classes that will raise runtime type errors due to invalid method resolution order (MRO)
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
 * Identifies classes with invalid MRO where a base class appears to the right of its subclass.
 * @param cls The problematic class with invalid inheritance hierarchy
 * @param superBase The base class that should not be a supertype of the right base
 * @param subBase The base class that should not be a subtype of the left base
 */
predicate exhibitsInvalidMRO(ClassObject cls, ClassObject superBase, ClassObject subBase) {
  cls.isNewStyle() and
  exists(int idx | 
    idx > 0 and 
    cls.getBaseType(idx) = subBase and 
    superBase = cls.getBaseType(idx - 1) and
    superBase = subBase.getAnImproperSuperType()
  )
}

/**
 * Primary query detecting classes with inconsistent method resolution order.
 * These classes will trigger runtime type errors during instantiation.
 */
from ClassObject cls, ClassObject superBase, ClassObject subBase
where exhibitsInvalidMRO(cls, superBase, subBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order (MRO) for bases $@ and $@.", superBase,
  superBase.getName(), subBase, subBase.getName()