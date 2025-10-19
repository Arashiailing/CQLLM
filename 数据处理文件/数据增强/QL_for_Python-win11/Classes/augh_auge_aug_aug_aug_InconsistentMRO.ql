/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions that may trigger runtime type errors due to conflicting method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes with inheritance hierarchies that create MRO conflicts
// by locating adjacent base classes with invalid superclass relationships
predicate problematic_mro(ClassObject cls, ClassObject baseA, ClassObject baseB) {
  // Verify the class uses new-style inheritance semantics
  cls.isNewStyle() and
  // Locate adjacent base classes in the inheritance declaration
  exists(int idx | 
    idx > 0 and 
    baseB = cls.getBaseType(idx) and 
    baseA = cls.getBaseType(idx - 1)
  ) and
  // Confirm the first base is an invalid superclass of the second base
  baseA = baseB.getAnImproperSuperType()
}

// Query classes with problematic MRO configurations and generate diagnostic messages
from ClassObject cls, ClassObject baseA, ClassObject baseB
where problematic_mro(cls, baseA, baseB)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()