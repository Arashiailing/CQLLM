/**
 * @name Inconsistent equality and inequality
 * @description Detects classes that violate the object model by implementing only one of the equality methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper function to return the names of equality comparison methods
string equalityMethodName() { result = "__eq__" or result = "__ne__" }

// Predicate to check if a class is decorated with total_ordering
predicate hasTotalOrderingDecorator(Class cls) {
  exists(Attribute decoratorAttr | 
    decoratorAttr = cls.getADecorator() | 
    decoratorAttr.getName() = "total_ordering"
  )
  or
  exists(Name decoratorName | 
    decoratorName = cls.getADecorator() | 
    decoratorName.getId() = "total_ordering"
  )
}

// Function to retrieve the implemented equality method from a class
CallableValue getImplementedEqualityMethod(ClassValue targetClass, string methodName) {
  result = targetClass.declaredAttribute(methodName) and 
  methodName = equalityMethodName()
}

// Function to determine which equality method is missing in a class
string getUnimplementedEqualityMethod(ClassValue targetClass) {
  not targetClass.declaresAttribute(result) and 
  result = equalityMethodName()
}

// Predicate to identify classes that break the equality contract
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

// Select classes that violate the equality contract and generate appropriate warning messages
from ClassValue targetClass, string implementedMethodName, string unimplementedMethodName, CallableValue equalityMethod
where breaksEqualityContract(targetClass, implementedMethodName, unimplementedMethodName, equalityMethod)
select equalityMethod, "Class $@ implements " + implementedMethodName + " but does not implement " + unimplementedMethodName + ".", targetClass,
  targetClass.getName()