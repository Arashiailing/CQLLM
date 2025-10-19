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

// Retrieves the immediate preceding base class of a specified base class in the inheritance hierarchy
// This function identifies the base class that appears immediately to the left of the target base
// in the class's base class list, which is crucial for MRO analysis
ClassObject getPrecedingBase(ClassObject classObj, ClassObject targetBase) {
  // Find a position index where index > 0, the index-th base of classObj is targetBase,
  // and return the (index-1)-th base as the preceding base
  exists(int index | 
    index > 0 and 
    classObj.getBaseType(index) = targetBase and 
    result = classObj.getBaseType(index - 1)
  )
}

// Determines if a class has an invalid method resolution order (MRO)
// This predicate checks if the inheritance hierarchy of a class violates the MRO rules,
// which would cause a TypeError at runtime when the class is defined
predicate hasInvalidMRO(ClassObject problemClass, ClassObject precedingBase, ClassObject followingBase) {
  // Verify that the target class is a new-style class and precedingBase is an improper supertype of followingBase
  problemClass.isNewStyle() and
  precedingBase = getPrecedingBase(problemClass, followingBase) and
  precedingBase = followingBase.getAnImproperSuperType()
}

// Query all classes with invalid MRO and generate diagnostic information
// This query identifies classes that would fail at runtime due to MRO issues
// and provides detailed error messages highlighting the problematic base classes
from ClassObject problemClass, ClassObject precedingBase, ClassObject followingBase
where hasInvalidMRO(problemClass, precedingBase, followingBase)
select problemClass,
  "Construction of class " + problemClass.getName() +
    " can fail due to invalid method resolution order(MRO) for bases $@ and $@.", precedingBase,
  precedingBase.getName(), followingBase, followingBase.getName()