/**
 * @name Inconsistent method resolution order
 * @description Identifies classes with inheritance hierarchies that cause runtime type errors due to invalid method resolution order (MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Detects MRO conflicts by analyzing inheritance relationships between consecutive base classes
predicate has_mro_conflict(ClassObject cls, ClassObject earlierBase, ClassObject laterBase) {
  // Focus on new-style classes which support proper MRO
  cls.isNewStyle() and
  // Identify consecutive base classes in the inheritance hierarchy
  exists(int baseIndex | 
    baseIndex > 0 and 
    cls.getBaseType(baseIndex) = laterBase and 
    earlierBase = cls.getBaseType(baseIndex - 1)
  ) and
  // Check for problematic inheritance: earlierBase is an improper supertype of laterBase
  earlierBase = laterBase.getAnImproperSuperType()
}

// Find classes with invalid MRO and generate diagnostic messages
from ClassObject faultyClass, ClassObject earlierBase, ClassObject laterBase
where has_mro_conflict(faultyClass, earlierBase, laterBase)
select faultyClass,
  "Class " + faultyClass.getName() +
    " construction may fail due to invalid method resolution order (MRO) between base classes $@ and $@.", earlierBase,
  earlierBase.getName(), laterBase, laterBase.getName()