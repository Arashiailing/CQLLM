/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions prone to runtime type errors caused by 
 *              inconsistent method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Detects MRO violations by identifying adjacent base classes where the first
// is an improper supertype of the second, violating Python's inheritance rules
predicate has_mro_violation(ClassObject cls, ClassObject base1, ClassObject base2) {
  // Limit analysis to new-style classes (Python 3+ inheritance model)
  cls.isNewStyle() and
  // Find consecutive base classes in the inheritance declaration
  exists(int idx | 
    idx > 0 and 
    // Extract adjacent base classes from inheritance list
    base2 = cls.getBaseType(idx) and 
    base1 = cls.getBaseType(idx - 1)
  ) and
  // Verify MRO violation condition: base1 must be an improper supertype of base2
  base1 = base2.getAnImproperSuperType()
}

// Query execution: Identify classes with MRO violations and generate diagnostic reports
from ClassObject cls, ClassObject base1, ClassObject base2
where has_mro_violation(cls, base1, base2)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", base1,
  base1.getName(), base2, base2.getName()