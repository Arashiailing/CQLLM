/**
 * @name Non-standard exception raised in special method
 * @description Special methods raising non-standard exceptions violate their expected interface contracts.
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

// Special method categorization helpers
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

// Exception type compatibility validation
predicate isCorrectExceptionType(string methodName, ClassObject exceptionType) {
  // TypeError compatibility for specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isIndexingMethod(methodName) or 
    isAttributeMethod(methodName)
  )
  or
  // Preferred exception type validation
  isPreferredExceptionType(methodName, exceptionType)
  or
  // Parent exception type validation
  isPreferredExceptionType(methodName, exceptionType.getASuperType())
}

// Preferred exception type mappings
predicate isPreferredExceptionType(string methodName, ClassObject exceptionType) {
  // Attribute methods require AttributeError
  isAttributeMethod(methodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods require LookupError
  isIndexingMethod(methodName) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods require TypeError
  isOrderingMethod(methodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods require ArithmeticError
  isArithmeticMethod(methodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method requires TypeError
  methodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Unnecessary exception handling cases
predicate isUnnecessaryRaise(string methodName, string suggestionMsg) {
  // Hash method should use __hash__ = None
  methodName = "__hash__" and suggestionMsg = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and suggestionMsg = "there is no need to implement the method at all."
}

// Function behavior analysis
predicate isAbstractFunction(FunctionObject func) {
  // Detect abstract method decorators
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject func, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  not exists(func.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not exceptionType = theStopIterationType()
}

// Main detection logic
from FunctionObject func, ClassObject exceptionType, string suggestionMsg
where
  // Target non-abstract special methods
  func.getFunction().isSpecialMethod() and
  not isAbstractFunction(func) and
  alwaysRaisesException(func, exceptionType) and
  (
    // Unnecessary exception cases
    isUnnecessaryRaise(func.getName(), suggestionMsg) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Incorrect exception type cases
    not isCorrectExceptionType(func.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(func.getName(), preferredException) |
      suggestionMsg = "raise " + preferredException.getName() + " instead"
    )
  )
select func, "Function always raises $@; " + suggestionMsg, exceptionType, exceptionType.toString()