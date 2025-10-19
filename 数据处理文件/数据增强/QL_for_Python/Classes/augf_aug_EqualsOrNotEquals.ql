/**
 * @name Inconsistent equality and inequality
 * @description Identifies classes violating the object model by implementing only one of the equality comparison methods (__eq__ or __ne__)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper function returning valid equality comparison method names
string getEqualityMethodName() { result = "__eq__" or result = "__ne__" }

// Predicate checking if a class uses the total_ordering decorator
predicate isDecoratedWithTotalOrdering(Class cls) {
  exists(Attribute decorator | 
    decorator = cls.getADecorator() | 
    decorator.getName() = "total_ordering"
  )
  or
  exists(Name decorator | 
    decorator = cls.getADecorator() | 
    decorator.getId() = "total_ordering"
  )
}

// Function retrieving an implemented equality method from a class
CallableValue getEqualityMethod(ClassValue targetClass, string methodName) {
  result = targetClass.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Function determining which equality method is missing in a class
string getMissingEqualityMethod(ClassValue targetClass) {
  not targetClass.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Predicate identifying classes violating the equality contract
predicate violatesEqualityContract(
  ClassValue targetClass, string implementedMethodName, 
  string missingMethodName, CallableValue equalityMethod
) {
  missingMethodName = getMissingEqualityMethod(targetClass) and
  equalityMethod = getEqualityMethod(targetClass, implementedMethodName) and
  not targetClass.failedInference(_) and
  not isDecoratedWithTotalOrdering(targetClass.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and implementedMethodName = "__eq__" and missingMethodName = "__ne__")
}

// Select classes violating the equality contract with warning messages
from ClassValue targetClass, string implementedMethodName, string missingMethodName, CallableValue equalityMethod
where violatesEqualityContract(targetClass, implementedMethodName, missingMethodName, equalityMethod)
select equalityMethod, "Class $@ implements " + implementedMethodName + " but does not implement " + missingMethodName + ".", targetClass,
  targetClass.getName()