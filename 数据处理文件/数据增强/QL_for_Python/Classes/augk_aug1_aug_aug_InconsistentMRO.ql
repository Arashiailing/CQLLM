/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions prone to runtime type errors caused by inconsistent method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Detects classes with inheritance hierarchies violating MRO consistency rules
predicate has_mro_violation(ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase) {
  // Verify class uses new-style inheritance (Python 3+ semantics)
  targetClass.isNewStyle() and
  // Identify consecutive base classes in inheritance declaration
  exists(int basePosition | 
    basePosition > 0 and 
    // laterBase immediately follows earlierBase in base class list
    laterBase = targetClass.getBaseType(basePosition) and 
    earlierBase = targetClass.getBaseType(basePosition - 1)
  ) and
  // Confirm earlierBase is an improper supertype of laterBase (creates MRO conflict)
  earlierBase = laterBase.getAnImproperSuperType()
}

// Report classes with MRO violations and their problematic base pairs
from ClassObject targetClass, ClassObject earlierBase, ClassObject laterBase
where has_mro_violation(targetClass, earlierBase, laterBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", earlierBase,
  earlierBase.getName(), laterBase, laterBase.getName()