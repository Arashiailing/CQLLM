/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions susceptible to runtime type errors resulting from inconsistent method resolution order (MRO) in inheritance hierarchies
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Identifies classes with problematic inheritance hierarchies that cause MRO conflicts
predicate problematic_mro(ClassObject cls, ClassObject base1, ClassObject base2) {
  // Verify the class uses new-style inheritance
  cls.isNewStyle() and
  // Locate adjacent base classes in inheritance declaration
  exists(int index | 
    index > 0 and 
    base2 = cls.getBaseType(index) and 
    base1 = cls.getBaseType(index - 1)
  ) and
  // Confirm improper superclass relationship between adjacent bases
  base1 = base2.getAnImproperSuperType()
}

// Query classes with invalid MRO and generate diagnostic messages
from ClassObject cls, ClassObject base1, ClassObject base2
where problematic_mro(cls, base1, base2)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", base1,
  base1.getName(), base2, base2.getName()