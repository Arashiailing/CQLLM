/**
 * @name Inconsistent equality and inequality implementation
 * @description Detects classes violating object model contracts by implementing only one of the equality comparison methods (__eq__ or __ne__)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Returns valid equality comparison method names
string equalityMethodName() { 
  result = ["__eq__", "__ne__"] 
}

// Checks if class has total_ordering decorator applied
predicate hasTotalOrderingDecorator(Class cls) {
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

// Retrieves implemented equality method from class
CallableValue getImplementedEqualityMethod(ClassValue cls, string method) { 
  result = cls.declaredAttribute(method) and 
  method = equalityMethodName()
}

// Identifies missing equality method in class
string getUnimplementedEqualityMethod(ClassValue cls) { 
  not cls.declaresAttribute(result) and 
  result = equalityMethodName()
}

// Detects classes violating equality contract
predicate violatesEqualityContract(
  ClassValue cls, string implementedMethod, 
  string missingMethod, CallableValue methodImpl
) {
  missingMethod = getUnimplementedEqualityMethod(cls) and
  methodImpl = getImplementedEqualityMethod(cls, implementedMethod) and
  not cls.failedInference(_) and
  not hasTotalOrderingDecorator(cls.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined, but not vice-versa */
  not (major_version() = 3 and implementedMethod = "__eq__" and missingMethod = "__ne__")
}

// Report classes with inconsistent equality implementations
from ClassValue cls, string implementedMethod, string missingMethod, CallableValue methodImpl
where violatesEqualityContract(cls, implementedMethod, missingMethod, methodImpl)
select methodImpl, "Class $@ implements " + implementedMethod + " but does not implement " + missingMethod + ".", cls,
  cls.getName()