/**
 * @name Inconsistent method resolution order
 * @description Detects class definitions that will raise a type error at runtime due to inconsistent method resolution order (MRO)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-mro
 */

import python

// Retrieves the immediate predecessor base class in the inheritance hierarchy
// This helper identifies the base class positioned immediately before the target base
// in the class's base class list, which is critical for MRO validation
ClassObject getPredecessorBase(ClassObject cls, ClassObject targetBase) {
  // Find a valid position index where the index-th base is targetBase,
  // and return the preceding base at position (index-1)
  exists(int position | 
    position > 0 and 
    cls.getBaseType(position) = targetBase and 
    result = cls.getBaseType(position - 1)
  )
}

// Validates if a class has an invalid method resolution order (MRO)
// This predicate checks inheritance hierarchy violations that would cause
// runtime TypeError during class definition
predicate hasInvalidMRO(ClassObject cls, ClassObject predecessorBase, ClassObject successorBase) {
  // Ensure the class is new-style and predecessorBase is an improper supertype of successorBase
  cls.isNewStyle() and
  predecessorBase = getPredecessorBase(cls, successorBase) and
  predecessorBase = successorBase.getAnImproperSuperType()
}

// Query classes with invalid MRO and generate diagnostic information
// This identifies classes that fail at runtime due to MRO violations,
// providing detailed error messages about problematic base classes
from ClassObject cls, ClassObject predecessorBase, ClassObject successorBase
where hasInvalidMRO(cls, predecessorBase, successorBase)
select cls,
  "Construction of class " + cls.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", predecessorBase,
  predecessorBase.getName(), successorBase, successorBase.getName()