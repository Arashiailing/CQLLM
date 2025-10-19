/**
 * @name Inconsistent equality and inequality implementation
 * @description Identifies classes that violate the object model by implementing only one of the equality methods (__eq__ or __ne__).
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
  result = "__eq__" 
  or 
  result = "__ne__" 
}

// Predicate that checks if a class has the total_ordering decorator
predicate hasTotalOrderingDecorator(Class klass) {
  exists(Attribute decoratorNode | 
    decoratorNode = klass.getADecorator() | 
    decoratorNode.getName() = "total_ordering"
  )
  or
  exists(Name nameNode | 
    nameNode = klass.getADecorator() | 
    nameNode.getId() = "total_ordering"
  )
}

// Function that retrieves the implemented equality method from a given class
CallableValue getImplementedEqualityMethod(ClassValue klass, string methodName) { 
  result = klass.declaredAttribute(methodName) and 
  methodName = equalityMethodName()
}

// Function that determines the missing equality method in a class
string getUnimplementedEqualityMethod(ClassValue klass) { 
  not klass.declaresAttribute(result) and 
  result = equalityMethodName()
}

// Predicate that identifies classes violating the equality contract
predicate breaksEqualityContract(
  ClassValue targetClass, string implementedMethodName, 
  string unimplementedMethodName, CallableValue equalityMethod
) {
  unimplementedMethodName = getUnimplementedEqualityMethod(targetClass) and
  equalityMethod = getImplementedEqualityMethod(targetClass, implementedMethodName) and
  not targetClass.failedInference(_) and
  not hasTotalOrderingDecorator(targetClass.getScope()) and
  /* Python 3 automatically implements __ne__ if __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and implementedMethodName = "__eq__" and unimplementedMethodName = "__ne__")
}

// Select classes violating the equality contract and generate corresponding warning messages
from ClassValue targetClass, string implementedMethodName, string unimplementedMethodName, CallableValue equalityMethod
where breaksEqualityContract(targetClass, implementedMethodName, unimplementedMethodName, equalityMethod)
select equalityMethod, "Class $@ implements " + implementedMethodName + " but does not implement " + unimplementedMethodName + ".", targetClass,
  targetClass.getName()