/**
 * @name Inconsistent equality and inequality
 * @description Identifies classes violating Python's object model by implementing only one of the equality comparison methods (__eq__ or __ne__).
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
string getEqualityMethodName() { result = "__eq__" or result = "__ne__" }

// Checks if a class uses the @total_ordering decorator
predicate isTotalOrderingDecorated(Class cls) {
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

// Retrieves an implemented equality method from a class
CallableValue findEqualityMethod(ClassValue targetClass, string methodName) {
  result = targetClass.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Determines which equality method is missing in a class
string getMissingEqualityMethod(ClassValue targetClass) {
  not targetClass.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Identifies classes violating the equality contract
predicate violatesEqualityContract(
  ClassValue targetClass, string presentMethod, 
  string missingMethod, CallableValue implementedMethod
) {
  // Get missing equality method
  missingMethod = getMissingEqualityMethod(targetClass) and
  // Get implemented equality method
  implementedMethod = findEqualityMethod(targetClass, presentMethod) and
  // Exclude classes with failed inference
  not targetClass.failedInference(_) and
  // Exclude classes with @total_ordering decorator
  not isTotalOrderingDecorated(targetClass.getScope()) and
  // Python 3 auto-implements __ne__ when __eq__ exists
  not (major_version() = 3 and presentMethod = "__eq__" and missingMethod = "__ne__")
}

// Select classes violating equality contract and generate warnings
from ClassValue targetClass, string presentMethod, string missingMethod, CallableValue implementedMethod
where violatesEqualityContract(targetClass, presentMethod, missingMethod, implementedMethod)
select implementedMethod, "Class $@ implements " + presentMethod + " but lacks " + missingMethod + ".", targetClass,
  targetClass.getName()