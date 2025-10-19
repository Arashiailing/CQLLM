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
 * This query detects when a class inherits from two classes where one is an
 * improper superclass of the other, creating an invalid method resolution order.
 */
from ClassObject problematicClass, ClassObject firstBase, ClassObject secondBase
where 
  // Ensure new-style class semantics
  problematicClass.isNewStyle() and
  // Check consecutive base classes for improper inheritance relationships
  exists(int index | 
    index > 0 and 
    firstBase = problematicClass.getBaseType(index - 1) and 
    secondBase = problematicClass.getBaseType(index) and
    firstBase = secondBase.getAnImproperSuperType()
  )
select problematicClass,
  "Construction of class " + problematicClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", firstBase,
  firstBase.getName(), secondBase, secondBase.getName()