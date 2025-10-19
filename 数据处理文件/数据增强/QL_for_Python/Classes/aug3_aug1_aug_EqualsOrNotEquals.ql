/**
 * @name Inconsistent equality and inequality implementation
 * @description Detects classes that violate the object model by implementing only one of the equality comparison methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper function that returns the names of equality comparison methods
string equalityMethodName() { 
  result in ["__eq__", "__ne__"] 
}

// Predicate that checks if a class has the total_ordering decorator
predicate hasTotalOrderingDecorator(Class cls) {
  exists(Attribute decoratorNode | 
    decoratorNode = cls.getADecorator() | 
    decoratorNode.getName() = "total_ordering"
  )
  or
  exists(Name nameNode | 
    nameNode = cls.getADecorator() | 
    nameNode.getId() = "total_ordering"
  )
}

// Function that retrieves the implemented equality method from a given class
CallableValue getImplementedEqualityMethod(ClassValue cls, string methodName) { 
  result = cls.declaredAttribute(methodName) and 
  methodName = equalityMethodName()
}

// Function that determines the missing equality method in a class
string getUnimplementedEqualityMethod(ClassValue cls) { 
  not cls.declaresAttribute(result) and 
  result = equalityMethodName()
}

// Predicate that identifies classes violating the equality contract
predicate breaksEqualityContract(
  ClassValue problematicClass, string implementedMethod, 
  string missingMethod, CallableValue implementedEqualityMethod
) {
  missingMethod = getUnimplementedEqualityMethod(problematicClass) and
  implementedEqualityMethod = getImplementedEqualityMethod(problematicClass, implementedMethod) and
  not problematicClass.failedInference(_) and
  not hasTotalOrderingDecorator(problematicClass.getScope()) and
  /* Python 3 automatically implements __ne__ if __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Select classes violating the equality contract and generate corresponding warning messages
from ClassValue problematicClass, string implementedMethod, string missingMethod, CallableValue implementedEqualityMethod
where breaksEqualityContract(problematicClass, implementedMethod, missingMethod, implementedEqualityMethod)
select implementedEqualityMethod, "Class $@ implements " + implementedMethod + " but does not implement " + missingMethod + ".", problematicClass,
  problematicClass.getName()