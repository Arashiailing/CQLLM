/**
 * @name Inconsistent equality and inequality
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
string getEqualityMethodName() { result = "__eq__" or result = "__ne__" }

// Predicate to determine if a class has the total_ordering decorator
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

// Function to fetch the equality method implemented by a class
CallableValue findImplementedEqualityMethod(ClassValue cls, string methodName) {
  result = cls.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Function to identify which equality method is not implemented by a class
string findMissingEqualityMethod(ClassValue cls) {
  not cls.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Predicate to detect classes that violate the equality contract
predicate violatesEqualityContract(
  ClassValue cls, string implementedMethod, 
  string missingMethod, CallableValue equalityMethodImpl
) {
  missingMethod = findMissingEqualityMethod(cls) and
  equalityMethodImpl = findImplementedEqualityMethod(cls, implementedMethod) and
  not cls.failedInference(_) and
  not isTotalOrderingDecorated(cls.getScope()) and
  /* In Python 3, __ne__ is automatically implemented when __eq__ is defined, but not the reverse */
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Select classes that violate the equality contract and generate appropriate warning messages
from ClassValue cls, string implementedMethod, string missingMethod, CallableValue equalityMethodImpl
where violatesEqualityContract(cls, implementedMethod, missingMethod, equalityMethodImpl)
select equalityMethodImpl, "Class $@ implements " + implementedMethod + " but does not implement " + missingMethod + ".", cls,
  cls.getName()