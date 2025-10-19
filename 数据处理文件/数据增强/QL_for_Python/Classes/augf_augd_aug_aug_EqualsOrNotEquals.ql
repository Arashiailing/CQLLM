/**
 * @name Equality and Inequality Method Inconsistency
 * @description Identifies classes violating object model symmetry by implementing only one of the equality comparison methods (__eq__ or __ne__) without its counterpart.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/inconsistent-equality
 */

import python

// Predicate to detect classes decorated with total_ordering
predicate isTotalOrderingDecorated(Class cls) {
  exists(Attribute decoratorAttr | 
    decoratorAttr = cls.getADecorator() | 
    decoratorAttr.getName() = "total_ordering"
  )
  or
  exists(Name decoratorId | 
    decoratorId = cls.getADecorator() | 
    decoratorId.getId() = "total_ordering"
  )
}

// Predicate identifying classes violating equality contract symmetry
predicate hasEqualityMethodAsymmetry(
  ClassValue classObj, string definedMethodName, 
  string undefinedMethodName, CallableValue methodImpl
) {
  // Check for exactly one equality method implementation
  (definedMethodName = "__eq__" or definedMethodName = "__ne__") and
  classObj.declaresAttribute(definedMethodName) and
  // Verify the counterpart method is missing
  (undefinedMethodName = "__eq__" or undefinedMethodName = "__ne__") and
  not classObj.declaresAttribute(undefinedMethodName) and
  // Ensure different methods are being compared
  definedMethodName != undefinedMethodName and
  // Retrieve the actual method implementation
  methodImpl = classObj.declaredAttribute(definedMethodName) and
  // Exclude classes with inference failures
  not classObj.failedInference(_) and
  // Exclude classes with total_ordering decorator
  not isTotalOrderingDecorated(classObj.getScope()) and
  // Exclude Python 3 auto-implementation of __ne__
  not (
    major_version() = 3 and
    definedMethodName = "__eq__" and
    undefinedMethodName = "__ne__"
  )
}

// Query to find classes with inconsistent equality implementations
from ClassValue classObj, string definedMethodName, string undefinedMethodName, CallableValue methodImpl
where hasEqualityMethodAsymmetry(classObj, definedMethodName, undefinedMethodName, methodImpl)
select methodImpl, "Class $@ implements " + definedMethodName + " but lacks " + undefinedMethodName + ".", classObj,
  classObj.getName()