/**
 * @name Non-standard exception raised in special method
 * @description Raising a non-standard exception in a special method violates expected interface conventions.
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

// Identifies special methods that handle attribute access operations
private predicate isAttributeSpecialMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Identifies special methods that handle container indexing operations
private predicate isIndexingSpecialMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Identifies special methods that implement arithmetic operations
private predicate isArithmeticSpecialMethod(string methodName) {
  methodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Identifies special methods that implement comparison operations
private predicate isOrderingSpecialMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

// Identifies special methods that handle type conversions
private predicate isCastSpecialMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Determines if an exception type is appropriate for a special method
predicate isValidExceptionTypeForMethod(string methodName, ClassObject exceptionType) {
  // Check direct preferred exception types
  isPreferredExceptionForMethod(methodName, exceptionType)
  or
  // Check inheritance from preferred exception types
  isPreferredExceptionForMethod(methodName, exceptionType.getASuperType())
  or
  // Special handling for TypeError-compatible cases
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isIndexingSpecialMethod(methodName) or 
    isAttributeSpecialMethod(methodName)
  )
}

// Identifies preferred exception types for specific special methods
predicate isPreferredExceptionForMethod(string methodName, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeSpecialMethod(methodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingSpecialMethod(methodName) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingSpecialMethod(methodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticSpecialMethod(methodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Identifies cases where raising exceptions is unnecessary
predicate isUnnecessaryExceptionRaise(string methodName, string suggestionMsg) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestionMsg = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastSpecialMethod(methodName) and suggestionMsg = "there is no need to implement the method at all."
}

// Identifies abstract methods through decorators
predicate isAbstractMethod(FunctionObject methodObj) {
  // Check for decorators containing "abstract"
  methodObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that consistently raise a specific exception
predicate alwaysRaisesSpecificException(FunctionObject methodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = methodObj.getARaisedType() and
  strictcount(methodObj.getARaisedType()) = 1 and
  not exists(methodObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query: detects special methods with non-standard exception handling
from FunctionObject specialMethodObj, ClassObject raisedExceptionClass, string suggestionMsg
where
  // Target special methods that aren't abstract
  specialMethodObj.getFunction().isSpecialMethod() and
  not isAbstractMethod(specialMethodObj) and
  alwaysRaisesSpecificException(specialMethodObj, raisedExceptionClass) and
  // Exclude NotImplementedError as it's a special case
  not raisedExceptionClass.getName() = "NotImplementedError" and
  (
    // Check for unnecessary exception cases
    isUnnecessaryExceptionRaise(specialMethodObj.getName(), suggestionMsg)
    or
    // Check for incorrect exception types
    (
      not isValidExceptionTypeForMethod(specialMethodObj.getName(), raisedExceptionClass) and
      exists(ClassObject preferredException | 
        isPreferredExceptionForMethod(specialMethodObj.getName(), preferredException) |
        suggestionMsg = "raise " + preferredException.getName() + " instead"
      )
    )
  )
select specialMethodObj, "Function always raises $@; " + suggestionMsg, raisedExceptionClass, raisedExceptionClass.toString()