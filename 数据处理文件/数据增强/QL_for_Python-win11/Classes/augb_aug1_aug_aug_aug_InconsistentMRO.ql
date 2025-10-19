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
from ClassObject targetCls, ClassObject baseA, ClassObject baseB
where 
  // Ensure new-style class semantics
  targetCls.isNewStyle() and
  // Check consecutive base classes for improper inheritance relationships
  exists(int position | 
    position > 0 and 
    baseB = targetCls.getBaseType(position) and 
    baseA = targetCls.getBaseType(position - 1) and
    baseA = baseB.getAnImproperSuperType()
  )
select targetCls,
  "Construction of class " + targetCls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", baseA,
  baseA.getName(), baseB, baseB.getName()