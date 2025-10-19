/**
 * @name Inconsistent equality and inequality implementation
 * @description Detects classes violating Python's object model by implementing only one of the equality comparison methods (__eq__ or __ne__).
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
string getEqualityMethodNames() { 
  result in ["__eq__", "__ne__"] 
}

// Checks if a class is decorated with @total_ordering
predicate hasTotalOrdering(Class cls) {
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

// Retrieves an implemented equality method from a class
CallableValue findEqualityMethod(ClassValue cls, string methodName) { 
  result = cls.declaredAttribute(methodName) and 
  methodName = getEqualityMethodNames()
}

// Identifies the missing equality method in a class
string getMissingEqualityMethod(ClassValue cls) { 
  not cls.declaresAttribute(result) and 
  result = getEqualityMethodNames()
}

// Detects classes violating the equality contract
predicate violatesEqualityContract(
  ClassValue violatingClass, string presentMethod, 
  string absentMethod, CallableValue implementedMethod
) {
  // Determine missing and present methods
  absentMethod = getMissingEqualityMethod(violatingClass) and
  implementedMethod = findEqualityMethod(violatingClass, presentMethod) and
  
  // Exclude classes with inference failures or @total_ordering
  not violatingClass.failedInference(_) and
  not hasTotalOrdering(violatingClass.getScope()) and
  
  // Exclude Python 3's automatic __ne__ implementation
  not (major_version() = 3 and presentMethod = "__eq__" and absentMethod = "__ne__")
}

// Report classes with inconsistent equality implementations
from ClassValue violatingClass, string presentMethod, string absentMethod, CallableValue implementedMethod
where violatesEqualityContract(violatingClass, presentMethod, absentMethod, implementedMethod)
select implementedMethod, "Class $@ implements " + presentMethod + " but does not implement " + absentMethod + ".", violatingClass,
  violatingClass.getName()