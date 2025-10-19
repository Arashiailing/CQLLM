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

// Detects classes with problematic inheritance hierarchies where base class ordering violates MRO rules
predicate has_mro_violation(ClassObject cls, ClassObject priorBase, ClassObject nextBase) {
  // Ensure the class is new-style (Python 3+ style classes)
  cls.isNewStyle() and
  // Find consecutive base classes in inheritance list
  exists(int position | 
    position > 0 and 
    // nextBase appears immediately after priorBase in base class list
    cls.getBaseType(position) = nextBase and 
    priorBase = cls.getBaseType(position - 1)
  ) and
  // Verify priorBase is an improper supertype of nextBase (creates MRO conflict)
  priorBase = nextBase.getAnImproperSuperType()
}

// Identify all classes with MRO violations and generate diagnostic messages
from ClassObject cls, ClassObject priorBase, ClassObject nextBase
where has_mro_violation(cls, priorBase, nextBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", priorBase,
  priorBase.getName(), nextBase, nextBase.getName()