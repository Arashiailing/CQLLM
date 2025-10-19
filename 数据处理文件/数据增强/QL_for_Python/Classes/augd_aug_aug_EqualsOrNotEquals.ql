/**
 * @name Equality and Inequality Method Inconsistency
 * @description Finds classes that break object model symmetry by defining only one of the equality comparison methods (__eq__ or __ne__) without the counterpart.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Predicate to detect classes decorated with total_ordering
predicate isTotalOrderingDecorated(Class cls) {
  exists(Attribute decoratorAttribute | 
    decoratorAttribute = cls.getADecorator() | 
    decoratorAttribute.getName() = "total_ordering"
  )
  or
  exists(Name decoratorIdentifier | 
    decoratorIdentifier = cls.getADecorator() | 
    decoratorIdentifier.getId() = "total_ordering"
  )
}

// Helper predicate to check if a class defines a specific equality method
predicate definesEqualityMethod(ClassValue cls, string methodName) {
  (methodName = "__eq__" or methodName = "__ne__") and
  cls.declaresAttribute(methodName)
}

// Helper predicate to check if a class does not define a specific equality method
predicate lacksEqualityMethod(ClassValue cls, string methodName) {
  (methodName = "__eq__" or methodName = "__ne__") and
  not cls.declaresAttribute(methodName)
}

// Helper predicate to check if we should exclude Python 3's automatic __ne__ implementation
predicate shouldExcludePython3AutoNe(string definedMethod, string undefinedMethod) {
  major_version() = 3 and
  definedMethod = "__eq__" and
  undefinedMethod = "__ne__"
}

// Predicate identifying classes violating equality contract symmetry
predicate hasEqualityMethodAsymmetry(
  ClassValue cls, string definedMethod, 
  string undefinedMethod, CallableValue methodDefinition
) {
  // Check for exactly one equality method implementation
  definesEqualityMethod(cls, definedMethod) and
  lacksEqualityMethod(cls, undefinedMethod) and
  // Ensure different methods are being compared
  definedMethod != undefinedMethod and
  // Retrieve the actual method implementation
  methodDefinition = cls.declaredAttribute(definedMethod) and
  // Exclude classes with inference failures
  not cls.failedInference(_) and
  // Exclude classes with total_ordering decorator
  not isTotalOrderingDecorated(cls.getScope()) and
  // Exclude Python 3 auto-implementation of __ne__
  not shouldExcludePython3AutoNe(definedMethod, undefinedMethod)
}

// Query to find classes with inconsistent equality implementations
from ClassValue cls, string definedMethod, string undefinedMethod, CallableValue methodDefinition
where hasEqualityMethodAsymmetry(cls, definedMethod, undefinedMethod, methodDefinition)
select methodDefinition, "Class $@ implements " + definedMethod + " but lacks " + undefinedMethod + ".", cls,
  cls.getName()