/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions that are prone to runtime type errors caused by an inconsistent method resolution order (MRO) in their inheritance hierarchy
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes with inheritance hierarchies violating MRO consistency rules
// by detecting problematic base class ordering that would cause runtime failures
predicate has_mro_violation(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Restrict analysis to new-style classes (Python 3+ model)
  targetClass.isNewStyle() and
  // Locate consecutive base classes in the inheritance hierarchy
  exists(int basePosition | 
    basePosition > 0 and 
    // secondBase immediately follows firstBase in base class declaration
    secondBase = targetClass.getBaseType(basePosition) and 
    firstBase = targetClass.getBaseType(basePosition - 1)
  ) and
  // Verify MRO violation: firstBase must be an improper supertype of secondBase
  firstBase = secondBase.getAnImproperSuperType()
}

// Query execution: Find all classes with MRO violations and generate diagnostic reports
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where has_mro_violation(targetClass, firstBase, secondBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()