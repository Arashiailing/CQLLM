/**
 * @name Inconsistent method resolution order
 * @description Detects classes with inheritance hierarchies that violate method resolution order (MRO) rules, which can lead to runtime type errors during class construction
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes where adjacent base classes in the inheritance hierarchy create MRO conflicts
predicate has_mro_violation(ClassObject problematicClass, ClassObject precedingBase, ClassObject followingBase) {
  // Focus on new-style classes (applicable in Python 3+)
  problematicClass.isNewStyle() and
  // Find consecutive base classes in the inheritance list
  exists(int positionIndex | 
    positionIndex > 0 and 
    // followingBase comes immediately after precedingBase in the base class list
    followingBase = problematicClass.getBaseType(positionIndex) and 
    precedingBase = problematicClass.getBaseType(positionIndex - 1)
  ) and
  // Confirm MRO violation: precedingBase is an improper supertype of followingBase
  precedingBase = followingBase.getAnImproperSuperType()
}

// Generate reports for classes with MRO violations, highlighting the conflicting base classes
from ClassObject problematicClass, ClassObject precedingBase, ClassObject followingBase
where has_mro_violation(problematicClass, precedingBase, followingBase)
select problematicClass,
  "Class " + problematicClass.getName() +
    " construction may fail due to invalid MRO between base classes $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()