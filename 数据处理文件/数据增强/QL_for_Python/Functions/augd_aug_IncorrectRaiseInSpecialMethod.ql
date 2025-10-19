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

// Identifies attribute-related special methods
private predicate isAttributeMethod(string methodNameStr) {
  methodNameStr = "__getattribute__" or 
  methodNameStr = "__getattr__" or 
  methodNameStr = "__setattr__"
}

// Identifies indexing-related special methods
private predicate isIndexingMethod(string methodNameStr) {
  methodNameStr = "__getitem__" or 
  methodNameStr = "__setitem__" or 
  methodNameStr = "__delitem__"
}

// Identifies arithmetic operation special methods
private predicate isArithmeticMethod(string methodNameStr) {
  methodNameStr in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Identifies ordering comparison special methods
private predicate isOrderingMethod(string methodNameStr) {
  (methodNameStr = "__lt__" or 
   methodNameStr = "__le__" or 
   methodNameStr = "__gt__" or 
   methodNameStr = "__ge__") 
  or 
  (methodNameStr = "__cmp__" and major_version() = 2)
}

// Identifies type conversion special methods
private predicate isCastMethod(string methodNameStr) {
  (methodNameStr = "__nonzero__" and major_version() = 2)
  or
  methodNameStr = "__int__" or 
  methodNameStr = "__float__" or 
  methodNameStr = "__long__" or 
  methodNameStr = "__trunc__" or 
  methodNameStr = "__complex__"
}

// Determines if exception type is appropriate for the special method
predicate isCorrectExceptionType(string methodNameStr, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or 
    methodNameStr = "__deepcopy__" or 
    methodNameStr = "__call__" or 
    isIndexingMethod(methodNameStr) or 
    isAttributeMethod(methodNameStr)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionType(methodNameStr, exceptionType.getASuperType())
}

// Determines preferred exception types for special methods
predicate isPreferredExceptionType(string methodNameStr, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodNameStr) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodNameStr) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodNameStr) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodNameStr) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodNameStr = "__bool__" and exceptionType = theTypeErrorType()
}

// Identifies cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodNameStr, string suggestionMessage) {
  // Hash method should use __hash__ = None instead
  methodNameStr = "__hash__" and suggestionMessage = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodNameStr) and suggestionMessage = "there is no need to implement the method at all."
}

// Identifies abstract functions
predicate isAbstractFunction(FunctionObject specialMethod) {
  // Check for decorators containing "abstract"
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that always raise a specific exception
predicate alwaysRaisesException(FunctionObject specialMethod, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query to identify special methods with non-standard exception handling
from FunctionObject specialMethod, ClassObject exceptionClass, string suggestionMessage
where
  // Filter for special methods that aren't abstract
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, exceptionClass) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(specialMethod.getName(), suggestionMessage) and 
    not exceptionClass.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(specialMethod.getName(), exceptionClass) and
    not exceptionClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(specialMethod.getName(), preferredException) |
      suggestionMessage = "raise " + preferredException.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestionMessage, exceptionClass, exceptionClass.toString()