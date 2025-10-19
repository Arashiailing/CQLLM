/**
 * @name Inconsistent equality and inequality
 * @description Identifies classes violating object model symmetry by implementing only one of the equality methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper predicate to identify classes decorated with total_ordering
predicate hasTotalOrderingDecorator(Class cls) {
  exists(Attribute decorator | 
    decorator = cls.getADecorator() and 
    decorator.getName() = "total_ordering"
  )
  or
  exists(Name decorator | 
    decorator = cls.getADecorator() and 
    decorator.getId() = "total_ordering"
  )
}

// Predicate that detects classes breaking the equality symmetry contract
predicate violatesEqualitySymmetry(
  ClassValue cls, string implementedMethod, 
  string missingMethod, CallableValue methodImpl
) {
  // Check for exactly one equality method implementation
  exists(string eqMethod | 
    (eqMethod = "__eq__" or eqMethod = "__ne__") and
    cls.declaresAttribute(eqMethod) and implementedMethod = eqMethod
  ) and
  // Ensure the other equality method is missing
  exists(string neqMethod | 
    (neqMethod = "__eq__" or neqMethod = "__ne__") and
    not cls.declaresAttribute(neqMethod) and missingMethod = neqMethod
  ) and
  // Verify we're comparing different methods
  implementedMethod != missingMethod and
  // Retrieve the actual method implementation
  methodImpl = cls.declaredAttribute(implementedMethod) and
  // Exclude classes with inference failures
  not cls.failedInference(_) and
  // Exclude classes with total_ordering decorator
  not hasTotalOrderingDecorator(cls.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined (but not vice-versa) */
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Main query to find classes with inconsistent equality implementations
from ClassValue cls, string implementedMethod, string missingMethod, CallableValue methodImpl
where violatesEqualitySymmetry(cls, implementedMethod, missingMethod, methodImpl)
select methodImpl, "Class $@ implements " + implementedMethod + " but lacks " + missingMethod + ".", cls,
  cls.getName()