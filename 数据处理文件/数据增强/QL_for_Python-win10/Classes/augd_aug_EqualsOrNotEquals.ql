/**
 * @name Inconsistent equality and inequality
 * @description Identifies classes violating object model contracts by implementing only one of equality methods (__eq__ or __ne__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Returns names of equality comparison methods
string getEqualityMethodName() { result = "__eq__" or result = "__ne__" }

// Checks if class has total_ordering decorator applied
predicate isTotalOrderingDecorated(Class cls) {
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

// Retrieves implemented equality method from a class
CallableValue findImplementedEqualityMethod(ClassValue cls, string methodName) {
  result = cls.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Determines missing equality method in a class
string findMissingEqualityMethod(ClassValue cls) {
  not cls.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Identifies classes violating equality contract
predicate violatesEqualityContract(
  ClassValue cls, string implementedMethod, 
  string missingMethod, CallableValue methodImpl
) {
  missingMethod = findMissingEqualityMethod(cls) and
  methodImpl = findImplementedEqualityMethod(cls, implementedMethod) and
  not cls.failedInference(_) and
  not isTotalOrderingDecorated(cls.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Select classes violating equality contract with warning messages
from ClassValue cls, string implementedMethod, string missingMethod, CallableValue methodImpl
where violatesEqualityContract(cls, implementedMethod, missingMethod, methodImpl)
select methodImpl, "Class $@ implements " + implementedMethod + " but does not implement " + missingMethod + ".", cls,
  cls.getName()