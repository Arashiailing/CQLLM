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

// Retrieves the immediate left base class of a specified base in the inheritance hierarchy
ClassObject getImmediateLeftBase(ClassObject targetClass, ClassObject baseClass) {
  // Find the position of the base class in the inheritance list
  exists(int baseIndex | 
    baseIndex > 0 and 
    targetClass.getBaseType(baseIndex) = baseClass
  |
    // Return the base class at the preceding position
    result = targetClass.getBaseType(baseIndex - 1)
  )
}

// Query classes with invalid method resolution order
from ClassObject problematicClass, ClassObject leftBaseClass, ClassObject rightBaseClass
where 
  // Verify that the target class is new-style
  problematicClass.isNewStyle() and
  // Check if there's a problematic inheritance structure
  leftBaseClass = getImmediateLeftBase(problematicClass, rightBaseClass) and
  // Verify that the left base is an improper super type of the right base
  leftBaseClass = rightBaseClass.getAnImproperSuperType()
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", leftBaseClass,
  leftBaseClass.getName(), rightBaseClass, rightBaseClass.getName()