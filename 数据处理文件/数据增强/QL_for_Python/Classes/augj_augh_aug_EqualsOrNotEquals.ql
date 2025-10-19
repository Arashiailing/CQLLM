/**
 * @name Inconsistent equality and inequality
 * @description Detects classes violating object model contracts by implementing only one equality method (__eq__ or __ne__)
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Helper function providing equality comparison method names
string getEqualityMethodName() { result = "__eq__" or result = "__ne__" }

// Predicate identifying classes with total_ordering decorator
predicate hasTotalOrderingDecorator(Class klass) {
  exists(Attribute decoratorNode | 
    decoratorNode = klass.getADecorator() | 
    decoratorNode.getName() = "total_ordering"
  )
  or
  exists(Name decoratorNameNode | 
    decoratorNameNode = klass.getADecorator() | 
    decoratorNameNode.getId() = "total_ordering"
  )
}

// Function retrieving implemented equality method from a class
CallableValue getImplementedEqualityMethod(ClassValue klass, string methodName) {
  result = klass.declaredAttribute(methodName) and 
  methodName = getEqualityMethodName()
}

// Function determining missing equality method in a class
string getMissingEqualityMethod(ClassValue klass) {
  not klass.declaresAttribute(result) and 
  result = getEqualityMethodName()
}

// Predicate detecting classes violating equality contract
predicate hasEqualityContractViolation(
  ClassValue klass, string implementedMethodName, 
  string missingMethodName, CallableValue implementedMethodCallable
) {
  missingMethodName = getMissingEqualityMethod(klass) and
  implementedMethodCallable = getImplementedEqualityMethod(klass, implementedMethodName) and
  not klass.failedInference(_) and
  not hasTotalOrderingDecorator(klass.getScope()) and
  /* Python 3 auto-implements __ne__ when __eq__ is defined, but not vice versa */
  not (major_version() = 3 and implementedMethodName = "__eq__" and missingMethodName = "__ne__")
}

// Select violating classes with descriptive warning messages
from ClassValue klass, string implementedMethodName, string missingMethodName, CallableValue implementedMethodCallable
where hasEqualityContractViolation(klass, implementedMethodName, missingMethodName, implementedMethodCallable)
select implementedMethodCallable, "Class $@ implements " + implementedMethodName + " but omits " + missingMethodName + ".", klass,
  klass.getName()