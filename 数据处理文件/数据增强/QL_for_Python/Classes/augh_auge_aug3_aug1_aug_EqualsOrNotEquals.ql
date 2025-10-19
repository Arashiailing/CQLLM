/**
 * @name Inconsistent equality and inequality implementation
 * @description Identifies classes violating Python's object model by implementing only one of the equality comparison methods (__eq__ or __ne__)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Checks for presence of total_ordering decorator on a class
predicate decoratedWithTotalOrdering(Class targetClass) {
  exists(Attribute decorator | 
    decorator = targetClass.getADecorator() | 
    decorator.getName() = "total_ordering"
  )
  or
  exists(Name decorator | 
    decorator = targetClass.getADecorator() | 
    decorator.getId() = "total_ordering"
  )
}

// Identifies classes with incomplete equality method implementations
from 
  ClassValue problematicClass, 
  string presentMethod, 
  string missingMethod, 
  CallableValue implementedMethod
where 
  // Verify one equality method exists while the other is missing
  exists(string eqMethod, string neMethod |
    eqMethod = "__eq__" and neMethod = "__ne__" and
    (
      // Case 1: __eq__ exists but __ne__ is missing
      (
        problematicClass.declaresAttribute(eqMethod) and
        not problematicClass.declaresAttribute(neMethod) and
        presentMethod = eqMethod and
        missingMethod = neMethod and
        implementedMethod = problematicClass.declaredAttribute(eqMethod)
      )
      or
      // Case 2: __ne__ exists but __eq__ is missing
      (
        problematicClass.declaresAttribute(neMethod) and
        not problematicClass.declaresAttribute(eqMethod) and
        presentMethod = neMethod and
        missingMethod = eqMethod and
        implementedMethod = problematicClass.declaredAttribute(neMethod)
      )
    )
  ) and
  // Exclude classes with failed type inference
  not problematicClass.failedInference(_) and
  // Exclude classes using total_ordering decorator
  not decoratedWithTotalOrdering(problematicClass.getScope()) and
  // Account for Python 3's automatic __ne__ implementation when __eq__ exists
  not (major_version() = 3 and presentMethod = "__eq__" and missingMethod = "__ne__")
select implementedMethod, 
  "Class $@ implements " + presentMethod + " but does not implement " + missingMethod + ".", 
  problematicClass, problematicClass.getName()