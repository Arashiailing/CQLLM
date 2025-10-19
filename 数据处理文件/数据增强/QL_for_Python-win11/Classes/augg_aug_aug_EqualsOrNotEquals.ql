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
predicate isTotalOrderingDecorated(Class targetClass) {
  exists(Attribute decoratorAttr | 
    decoratorAttr = targetClass.getADecorator() | 
    decoratorAttr.getName() = "total_ordering"
  )
  or
  exists(Name decoratorName | 
    decoratorName = targetClass.getADecorator() | 
    decoratorName.getId() = "total_ordering"
  )
}

// Predicate that detects classes breaking the equality symmetry contract
predicate breaksEqualitySymmetry(
  ClassValue targetClass, string presentMethod, 
  string absentMethod, CallableValue existingMethod
) {
  // Check for exactly one equality method implementation
  exists(string equalityMethod | 
    equalityMethod = "__eq__" or equalityMethod = "__ne__" |
    targetClass.declaresAttribute(equalityMethod) and presentMethod = equalityMethod
  ) and
  // Ensure the other equality method is missing
  exists(string inequalityMethod | 
    inequalityMethod = "__eq__" or inequalityMethod = "__ne__" |
    not targetClass.declaresAttribute(inequalityMethod) and absentMethod = inequalityMethod
  ) and
  // Verify we're comparing different methods
  presentMethod != absentMethod and
  // Retrieve the actual method implementation
  existingMethod = targetClass.declaredAttribute(presentMethod) and
  // Exclude classes with inference failures
  not targetClass.failedInference(_) and
  // Exclude classes with total_ordering decorator
  not isTotalOrderingDecorated(targetClass.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined (but not vice-versa) */
  not (major_version() = 3 and presentMethod = "__eq__" and absentMethod = "__ne__")
}

// Main query to find classes with inconsistent equality implementations
from ClassValue targetClass, string presentMethod, string absentMethod, CallableValue existingMethod
where breaksEqualitySymmetry(targetClass, presentMethod, absentMethod, existingMethod)
select existingMethod, "Class $@ implements " + presentMethod + " but lacks " + absentMethod + ".", targetClass,
  targetClass.getName()