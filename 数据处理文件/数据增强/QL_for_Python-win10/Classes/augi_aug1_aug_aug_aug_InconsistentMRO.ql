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
predicate has_mro_conflict(ClassObject cls, ClassObject earlierBase, ClassObject laterBase) {
  // Validate new-style class compliance
  cls.isNewStyle() and
  // Identify conflicting base classes in inheritance declaration
  exists(int idx | 
    idx > 0 and 
    laterBase = cls.getBaseType(idx) and 
    earlierBase = cls.getBaseType(idx - 1) and
    // Verify improper superclass relationship
    earlierBase = laterBase.getAnImproperSuperType()
  )
}

/**
 * Main query that identifies classes with invalid MRO and provides diagnostic information.
 * The query reports classes that cannot be constructed due to MRO conflicts between their base classes.
 */
from ClassObject cls, ClassObject earlierBase, ClassObject laterBase
where has_mro_conflict(cls, earlierBase, laterBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", earlierBase,
  earlierBase.getName(), laterBase, laterBase.getName()