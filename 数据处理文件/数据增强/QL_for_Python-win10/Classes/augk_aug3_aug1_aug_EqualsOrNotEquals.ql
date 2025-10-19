/**
 * @name Inconsistent equality and inequality implementation
 * @description Identifies classes violating object model principles by implementing only one of the equality comparison methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper function returning equality comparison method names
string getEqualityMethodName() { 
  result in ["__eq__", "__ne__"] 
}

// Predicate detecting classes with total_ordering decorator
predicate usesTotalOrderingDecorator(Class targetClass) {
  exists(Attribute decorator | 
    decorator = targetClass.getADecorator() | 
    decorator.getName() = "total_ordering"
  )
  or
  exists(Name decoratorName | 
    decoratorName = targetClass.getADecorator() | 
    decoratorName.getId() = "total_ordering"
  )
}

// Function retrieving implemented equality method from a class
CallableValue findImplementedEqualityMethod(ClassValue targetClass, string methodName) { 
  result = targetClass.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Function determining missing equality method in a class
string findMissingEqualityMethod(ClassValue targetClass) { 
  not targetClass.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Predicate identifying classes violating equality contract
predicate violatesEqualityContract(
  ClassValue nonCompliantClass, string presentMethodName, 
  string absentMethodName, CallableValue implementedMethod
) {
  absentMethodName = findMissingEqualityMethod(nonCompliantClass) and
  implementedMethod = findImplementedEqualityMethod(nonCompliantClass, presentMethodName) and
  not nonCompliantClass.failedInference(_) and
  not usesTotalOrderingDecorator(nonCompliantClass.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and presentMethodName = "__eq__" and absentMethodName = "__ne__")
}

// Select classes violating equality contract with diagnostic messages
from ClassValue nonCompliantClass, string presentMethodName, string absentMethodName, CallableValue implementedMethod
where violatesEqualityContract(nonCompliantClass, presentMethodName, absentMethodName, implementedMethod)
select implementedMethod, "Class $@ implements " + presentMethodName + " but does not implement " + absentMethodName + ".", nonCompliantClass,
  nonCompliantClass.getName()