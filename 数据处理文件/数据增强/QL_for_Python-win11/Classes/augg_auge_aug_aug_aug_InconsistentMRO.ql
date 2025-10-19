/**
 * @name Inconsistent method resolution order
 * @description Identifies class definitions that may cause runtime type errors due to inconsistent method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Main query: Detect classes with inheritance hierarchies that produce MRO conflicts
// by identifying adjacent base classes with improper superclass relationships
from ClassObject cls, ClassObject base1, ClassObject base2
where 
  // Ensure the class uses new-style inheritance semantics
  cls.isNewStyle() and
  // Find adjacent base classes in the inheritance declaration
  exists(int baseIndex | 
    baseIndex > 0 and 
    base2 = cls.getBaseType(baseIndex) and 
    base1 = cls.getBaseType(baseIndex - 1)
  ) and
  // Verify the first base is an improper superclass of the second base
  base1 = base2.getAnImproperSuperType()
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", base1,
  base1.getName(), base2, base2.getName()