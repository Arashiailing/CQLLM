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

// Detects classes with inheritance hierarchies that produce MRO conflicts
// by identifying adjacent base classes with improper superclass relationships
predicate problematic_mro(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Ensure the class uses new-style inheritance semantics
  targetClass.isNewStyle() and
  // Find adjacent base classes in the inheritance declaration
  exists(int baseIndex | 
    baseIndex > 0 and 
    secondBase = targetClass.getBaseType(baseIndex) and 
    firstBase = targetClass.getBaseType(baseIndex - 1)
  ) and
  // Verify the first base is an improper superclass of the second base
  firstBase = secondBase.getAnImproperSuperType()
}

// Query classes with invalid MRO configurations and generate diagnostic messages
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where problematic_mro(targetClass, firstBase, secondBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()