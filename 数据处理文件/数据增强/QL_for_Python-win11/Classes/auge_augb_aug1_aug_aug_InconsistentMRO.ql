/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions with inheritance hierarchies that violate method resolution order (MRO) consistency, potentially causing runtime type errors
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes violating MRO consistency rules in their inheritance hierarchy
// by detecting problematic base class sequences that would trigger runtime failures
predicate has_mro_violation(ClassObject problematicClass, ClassObject baseA, ClassObject baseB) {
  // Limit analysis to new-style classes (Python 3+ inheritance model)
  problematicClass.isNewStyle() and
  // Find consecutive base classes in the inheritance declaration
  exists(int index | 
    index > 0 and 
    // baseB immediately follows baseA in the base class list
    baseB = problematicClass.getBaseType(index) and 
    baseA = problematicClass.getBaseType(index - 1) and
    // Verify MRO violation: baseA must be an improper supertype of baseB
    baseA = baseB.getAnImproperSuperType()
  )
}

// Main query: Identify classes with MRO violations and generate diagnostic reports
from ClassObject problematicClass, ClassObject baseA, ClassObject baseB
where has_mro_violation(problematicClass, baseA, baseB)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()