/**
 * @name Inconsistent method resolution order
 * @description Identifies classes with inheritance hierarchies that violate method resolution order (MRO) rules, potentially causing runtime type errors
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes where consecutive base classes create MRO conflicts
predicate has_mro_violation(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Restrict to new-style classes (Python 3+)
  targetClass.isNewStyle() and
  // Locate adjacent base classes in inheritance hierarchy
  exists(int index | 
    index > 0 and 
    // secondBase follows firstBase in base class list
    secondBase = targetClass.getBaseType(index) and 
    firstBase = targetClass.getBaseType(index - 1)
  ) and
  // Verify MRO violation: firstBase is improper supertype of secondBase
  firstBase = secondBase.getAnImproperSuperType()
}

// Report classes with MRO violations and their conflicting bases
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where has_mro_violation(targetClass, firstBase, secondBase)
select targetClass,
  "Class " + targetClass.getName() +
    " construction may fail due to invalid MRO between base classes $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()