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

// Special method classification predicates
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

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

private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Exception type validation logic
predicate isCorrectExceptionType(string methodName, ClassObject exceptionType) {
  // Validate TypeError compatibility for specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isIndexingMethod(methodName) or 
    isAttributeMethod(methodName)
  )
  or
  // Validate preferred exception types
  isPreferredExceptionType(methodName, exceptionType)
  or
  // Validate parent exception types
  isPreferredExceptionType(methodName, exceptionType.getASuperType())
}

// Preferred exception type definitions
predicate isPreferredExceptionType(string methodName, ClassObject exceptionType) {
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

// Unnecessary exception handling detection
predicate isUnnecessaryRaise(string methodName, string recommendationText) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and recommendationText = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and recommendationText = "there is no need to implement the method at all."
}

// Function behavior analysis predicates
predicate isAbstractFunction(FunctionObject methodObj) {
  // Check for decorators containing "abstract"
  methodObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject methodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = methodObj.getARaisedType() and
  strictcount(methodObj.getARaisedType()) = 1 and
  not exists(methodObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query logic
from FunctionObject methodObj, ClassObject exceptionType, string recommendationText
where
  // Identify non-abstract special methods
  methodObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(methodObj) and
  alwaysRaisesException(methodObj, exceptionType) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(methodObj.getName(), recommendationText) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(methodObj.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(methodObj.getName(), preferredException) |
      recommendationText = "raise " + preferredException.getName() + " instead"
    )
  )
select methodObj, "Function always raises $@; " + recommendationText, exceptionType, exceptionType.toString()