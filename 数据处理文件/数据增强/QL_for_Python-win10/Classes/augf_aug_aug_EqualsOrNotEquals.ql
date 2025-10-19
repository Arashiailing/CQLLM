/**
 * @name Inconsistent equality and inequality
 * @description Detects classes that break object model symmetry by implementing only one of the equality methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Predicate to identify classes decorated with total_ordering
predicate usesTotalOrdering(Class classObj) {
  exists(Attribute decoratorAttribute | 
    decoratorAttribute = classObj.getADecorator() | 
    decoratorAttribute.getName() = "total_ordering"
  )
  or
  exists(Name decoratorIdentifier | 
    decoratorIdentifier = classObj.getADecorator() | 
    decoratorIdentifier.getId() = "total_ordering"
  )
}

// Helper predicate to check if a class declares a specific equality method
predicate declaresEqualityMethod(ClassValue classObj, string methodName) {
  (methodName = "__eq__" or methodName = "__ne__") and
  classObj.declaresAttribute(methodName)
}

// Helper predicate to check if a class lacks a specific equality method
predicate lacksEqualityMethod(ClassValue classObj, string methodName) {
  (methodName = "__eq__" or methodName = "__ne__") and
  not classObj.declaresAttribute(methodName)
}

// Predicate identifying classes violating equality contract symmetry
predicate breaksEqualitySymmetry(
  ClassValue classObj, string definedMethod, 
  string undefinedMethod, CallableValue methodDefinition
) {
  // Check for exactly one equality method implementation
  exists(string equalityMethod | 
    declaresEqualityMethod(classObj, equalityMethod) and
    definedMethod = equalityMethod
  ) and
  exists(string inequalityMethod | 
    lacksEqualityMethod(classObj, inequalityMethod) and
    undefinedMethod = inequalityMethod
  ) and
  // Ensure different methods are being compared
  definedMethod != undefinedMethod and
  // Retrieve the actual method implementation
  methodDefinition = classObj.declaredAttribute(definedMethod) and
  // Exclude classes with inference failures
  not classObj.failedInference(_) and
  // Exclude classes with total_ordering decorator
  not usesTotalOrdering(classObj.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined (but not vice-versa) */
  not (major_version() = 3 and definedMethod = "__eq__" and undefinedMethod = "__ne__")
}

// Query to find classes with inconsistent equality implementations
from ClassValue classObj, string definedMethod, string undefinedMethod, CallableValue methodDefinition
where breaksEqualitySymmetry(classObj, definedMethod, undefinedMethod, methodDefinition)
select methodDefinition, "Class $@ implements " + definedMethod + " but lacks " + undefinedMethod + ".", classObj,
  classObj.getName()