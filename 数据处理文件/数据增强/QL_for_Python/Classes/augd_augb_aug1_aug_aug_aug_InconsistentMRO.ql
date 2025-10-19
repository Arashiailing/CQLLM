/**
 * @name Inconsistent method resolution order
 * @description Detects Python classes with inheritance hierarchies causing MRO conflicts,
 *              which may lead to runtime type errors during class construction
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

/**
 * Identifies classes that cannot be constructed due to inheritance conflicts.
 * The query detects when a class inherits from two classes where one is an
 * improper superclass of the other, creating an invalid method resolution order.
 */
from ClassObject targetClass, ClassObject firstBase, ClassObject secondBase
where 
  // Restrict analysis to new-style classes with proper inheritance semantics
  targetClass.isNewStyle() and
  // Check for consecutive base classes with problematic inheritance relationships
  exists(int baseIndex | 
    // Ensure we're examining valid base class positions (skip first base)
    baseIndex > 0 and
    // Identify consecutive base classes in inheritance hierarchy
    secondBase = targetClass.getBaseType(baseIndex) and 
    firstBase = targetClass.getBaseType(baseIndex - 1) and
    // Detect improper inheritance where firstBase is an ancestor of secondBase
    firstBase = secondBase.getAnImproperSuperType()
  )
select targetClass,
  "Construction of class " + targetClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()