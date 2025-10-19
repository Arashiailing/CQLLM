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

// Detects MRO conflicts by checking inheritance relationships between consecutive base classes
predicate has_mro_conflict(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Only analyze new-style classes which support proper MRO
  targetClass.isNewStyle() and
  // Find consecutive base classes in inheritance hierarchy
  exists(int index | 
    index > 0 and 
    targetClass.getBaseType(index) = secondBase and 
    firstBase = targetClass.getBaseType(index - 1)
  ) and
  // Verify problematic inheritance: firstBase is an improper supertype of secondBase
  firstBase = secondBase.getAnImproperSuperType()
}

// Identify classes with invalid MRO and generate diagnostic messages
from ClassObject problematicClass, ClassObject priorBase, ClassObject nextBase
where has_mro_conflict(problematicClass, priorBase, nextBase)
select problematicClass,
  "Class " + problematicClass.getName() +
    " construction may fail due to invalid method resolution order (MRO) between base classes $@ and $@.", priorBase,
  priorBase.getName(), nextBase, nextBase.getName()