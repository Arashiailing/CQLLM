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
 * Retrieves the immediate left base class of a given base class in a class's inheritance hierarchy.
 * For a class `cls` and its base class `baseClass`, this function returns the base class
 * that appears immediately to the left of `baseClass` in the base class list.
 */
ClassObject getLeftBaseClass(ClassObject cls, ClassObject baseClass) {
  // There exists an index such that the base class at that index is `baseClass`,
  // and the result is the base class at the previous index.
  exists(int index |
    index > 0 and
    cls.getBaseType(index) = baseClass and
    result = cls.getBaseType(index - 1)
  )
}

/**
 * Determines if a class has an invalid method resolution order (MRO).
 * An MRO is considered invalid if a base class appears to the left of another base class
 * that is one of its improper super types, which would cause a type error at runtime.
 */
predicate hasInvalidMRO(ClassObject targetClass, ClassObject leftBase, ClassObject rightBase) {
  // The target class must be a new-style class.
  targetClass.isNewStyle() and
  // The left base is immediately to the left of the right base in the target class's base list.
  leftBase = getLeftBaseClass(targetClass, rightBase) and
  // The left base is an improper super type of the right base, creating an MRO conflict.
  leftBase = rightBase.getAnImproperSuperType()
}

// Select all classes with an invalid MRO and generate appropriate warning messages.
from ClassObject targetClass, ClassObject leftBase, ClassObject rightBase
where hasInvalidMRO(targetClass, leftBase, rightBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.",
  leftBase, leftBase.getName(), rightBase, rightBase.getName()