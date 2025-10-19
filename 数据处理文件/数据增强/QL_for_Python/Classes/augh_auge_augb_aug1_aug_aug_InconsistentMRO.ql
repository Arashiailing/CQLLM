/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions with inheritance hierarchies that violate method resolution order (MRO) consistency, potentially causing runtime type errors during class construction
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Detects classes violating MRO consistency by identifying problematic base class sequences
// that would cause runtime failures during class construction due to inheritance hierarchy conflicts
predicate has_mro_violation(ClassObject problematicClass, ClassObject baseA, ClassObject baseB) {
  // Restrict analysis to new-style classes (Python 3+ inheritance model)
  problematicClass.isNewStyle() and
  // Identify consecutive base classes in inheritance declaration
  exists(int position | 
    position > 0 and 
    // Retrieve adjacent base classes in the inheritance hierarchy
    baseA = problematicClass.getBaseType(position - 1) and 
    baseB = problematicClass.getBaseType(position) and
    // Verify MRO violation: baseA must be an improper supertype of baseB
    baseA = baseB.getAnImproperSuperType()
  )
}

// Primary query: Locate classes with MRO violations and generate diagnostic reports
from ClassObject problematicClass, ClassObject baseA, ClassObject baseB
where has_mro_violation(problematicClass, baseA, baseB)
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()