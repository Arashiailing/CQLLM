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
 * Retrieves the immediate left base class in the inheritance hierarchy
 * @param cls - The class being analyzed
 * @param baseClass - The target base class
 * @return The base class immediately to the left of baseClass in cls's inheritance list
 */
ClassObject getImmediateLeftBase(ClassObject cls, ClassObject baseClass) {
  exists(int position |
    position > 0 and
    cls.getBaseType(position) = baseClass and
    result = cls.getBaseType(position - 1)
  )
}

/**
 * Determines if a class has an invalid method resolution order (MRO)
 * @param targetClass - The class to check for MRO issues
 * @param leftBase - The left base class in the inheritance hierarchy
 * @param rightBase - The right base class in the inheritance hierarchy
 */
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftBase, ClassObject rightBase) {
  targetClass.isNewStyle() and
  leftBase = getImmediateLeftBase(targetClass, rightBase) and
  leftBase = rightBase.getAnImproperSuperType()
}

// Identify classes with invalid MRO and generate error reports
from ClassObject cls, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(cls, leftBase, rightBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBase,
  leftBase.getName(), rightBase, rightBase.getName()