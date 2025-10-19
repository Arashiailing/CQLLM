/**
 * @name Inconsistent equality and inequality implementation
 * @description Detects classes violating the object model by implementing only one of equality comparison methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Provides names of equality comparison methods
string getEqualityMethodName() { 
  result in ["__eq__", "__ne__"] 
}

// Verifies if class has total_ordering decorator applied
predicate isTotalOrderingDecorated(Class cls) {
  exists(Attribute decorator | 
    decorator = cls.getADecorator() | 
    decorator.getName() = "total_ordering"
  )
  or
  exists(Name decoratorName | 
    decoratorName = cls.getADecorator() | 
    decoratorName.getId() = "total_ordering"
  )
}

// Retrieves implemented equality method from class
CallableValue findEqualityMethod(ClassValue cls, string methodName) { 
  result = cls.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Determines missing equality method in class
string findMissingEqualityMethod(ClassValue cls) { 
  not cls.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Identifies classes violating equality contract
predicate hasEqualityViolation(
  ClassValue problematicClass, string implementedMethod, 
  string missingMethod, CallableValue existingMethod
) {
  // Identify missing method in class
  missingMethod = findMissingEqualityMethod(problematicClass) and
  
  // Locate implemented equality method
  existingMethod = findEqualityMethod(problematicClass, implementedMethod) and
  
  // Exclude classes with inference failures
  not problematicClass.failedInference(_) and
  
  // Exclude total_ordering decorated classes
  not isTotalOrderingDecorated(problematicClass.getScope()) and
  
  // Python 3 auto-implements __ne__ when __eq__ exists
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Generate warnings for violating classes
from ClassValue problematicClass, string implementedMethod, string missingMethod, CallableValue existingMethod
where hasEqualityViolation(problematicClass, implementedMethod, missingMethod, existingMethod)
select existingMethod, "Class $@ implements " + implementedMethod + " but does not implement " + missingMethod + ".", problematicClass,
  problematicClass.getName()