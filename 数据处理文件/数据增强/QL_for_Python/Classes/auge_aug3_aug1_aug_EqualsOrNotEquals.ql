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

// Returns the names of equality comparison methods
string equalityMethodName() { 
  result in ["__eq__", "__ne__"] 
}

// Checks if a class is decorated with total_ordering
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

// Retrieves the implemented equality method from a class
CallableValue getImplementedEqualityMethod(ClassValue cls, string methodName) { 
  result = cls.declaredAttribute(methodName) and 
  methodName = equalityMethodName()
}

// Determines the missing equality method in a class
string getUnimplementedEqualityMethod(ClassValue cls) { 
  not cls.declaresAttribute(result) and 
  result = equalityMethodName()
}

// Identifies classes violating the equality contract
predicate violatesEqualityContract(
  ClassValue violatingClass, string existingMethod, 
  string absentMethod, CallableValue equalityMethod
) {
  // Get the missing method in the class
  absentMethod = getUnimplementedEqualityMethod(violatingClass) and
  
  // Get the implemented equality method
  equalityMethod = getImplementedEqualityMethod(violatingClass, existingMethod) and
  
  // Exclude classes with failed inference
  not violatingClass.failedInference(_) and
  
  // Exclude classes with total_ordering decorator
  not hasTotalOrderingDecorator(violatingClass.getScope()) and
  
  // Python 3 auto-implements __ne__ when __eq__ is defined
  not (major_version() = 3 and existingMethod = "__eq__" and absentMethod = "__ne__")
}

// Generate warnings for classes violating the equality contract
from ClassValue violatingClass, string existingMethod, string absentMethod, CallableValue equalityMethod
where violatesEqualityContract(violatingClass, existingMethod, absentMethod, equalityMethod)
select equalityMethod, "Class $@ implements " + existingMethod + " but does not implement " + absentMethod + ".", violatingClass,
  violatingClass.getName()