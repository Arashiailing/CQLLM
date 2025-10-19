/**
 * @name Non-standard exception raised in special method
 * @description Raising a non-standard exception in a special method alters the expected interface of that method.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unexpected-raise-in-special-method
 */

import python

// Predicate to identify attribute-related special methods
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Predicate to identify indexing-related special methods
private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Predicate to identify arithmetic operation special methods
private predicate isArithmeticMethod(string methodName) {
  methodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Predicate to identify ordering comparison special methods
private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__")
  or
  (methodName = "__cmp__" and major_version() = 2)
}

// Predicate to identify type conversion special methods
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Predicate to determine if exception type is appropriate for special method
predicate isValidExceptionType(string methodName, ClassObject exceptionType) {
  // Valid TypeError cases for specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or
    methodName = "__deepcopy__" or
    methodName = "__call__" or
    isIndexingMethod(methodName) or
    isAttributeMethod(methodName)
  )
  or
  // Check against preferred exception types
  isPreferredException(methodName, exceptionType)
  or
  // Check parent types against preferred exceptions
  isPreferredException(methodName, exceptionType.getASuperType())
}

// Predicate to identify preferred exception types for special methods
predicate isPreferredException(string methodName, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Predicate to identify cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodName, string recommendation) {
  // __hash__ methods should use __hash__ = None instead
  methodName = "__hash__" and recommendation = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and recommendation = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject functionObj) {
  // Check for abstract decorator
  functionObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Predicate to identify functions that always raise a specific exception
predicate consistentlyRaises(FunctionObject functionObj, ClassObject exceptionType) {
  // Function raises only this exception type
  exceptionType = functionObj.getARaisedType() and
  strictcount(functionObj.getARaisedType()) = 1 and
  // No normal exit paths
  not exists(functionObj.getFunction().getANormalExit()) and
  // Exclude StopIteration (equivalent to return in generators)
  not exceptionType = theStopIterationType()
}

// Main query to detect non-standard exceptions in special methods
from FunctionObject methodObj, ClassObject exceptionType, string recommendation
where
  // Target special methods that aren't abstract
  methodObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(methodObj) and
  consistentlyRaises(methodObj, exceptionType) and
  (
    // Case 1: Unnecessary exception raising
    isUnnecessaryRaise(methodObj.getName(), recommendation) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Case 2: Incorrect exception type with recommended alternative
    not isValidExceptionType(methodObj.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredType | 
      isPreferredException(methodObj.getName(), preferredType) |
      recommendation = "raise " + preferredType.getName() + " instead"
    )
  )
select methodObj, "Function always raises $@; " + recommendation, exceptionType, exceptionType.toString()