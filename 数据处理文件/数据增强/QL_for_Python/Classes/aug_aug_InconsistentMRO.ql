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

// Identifies classes with invalid MRO through analysis of base class relationships
predicate problematic_mro(ClassObject targetClass, ClassObject firstBase, ClassObject secondBase) {
  // Ensures the target class is new-style and has an issue with base class ordering
  targetClass.isNewStyle() and
  // Locates a base class that directly precedes another in the inheritance list
  exists(int idx | 
    idx > 0 and 
    targetClass.getBaseType(idx) = secondBase and 
    firstBase = targetClass.getBaseType(idx - 1)
  ) and
  // Confirms that the first base is an improper supertype of the second base
  firstBase = secondBase.getAnImproperSuperType()
}

// Finds all classes with invalid MRO and produces diagnostic messages
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where problematic_mro(targetClass, firstBase, secondBase)
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()