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

// Helper predicate to identify attribute-related special methods
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Helper predicate to identify indexing-related special methods
private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Helper predicate to identify arithmetic operation special methods
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

// Helper predicate to identify ordering comparison special methods
private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

// Helper predicate to identify type conversion special methods
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Determines if an exception type is appropriate for a given special method
predicate isCorrectExceptionType(string methodName, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
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
  isPreferredExceptionType(methodName, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionType(methodName, exceptionType.getASuperType())
}

// Identifies preferred exception types for special methods
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

// Identifies cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodName, string suggestionMessage) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestionMessage = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and suggestionMessage = "there is no need to implement the method at all."
}

// Identifies abstract functions
predicate isAbstractFunction(FunctionObject functionObj) {
  // Check for decorators containing "abstract"
  functionObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that always raise a specific exception
predicate alwaysRaisesException(FunctionObject functionObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = functionObj.getARaisedType() and
  strictcount(functionObj.getARaisedType()) = 1 and
  not exists(functionObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query to identify special methods with non-standard exception handling
from FunctionObject functionObj, ClassObject exceptionClass, string suggestionMessage
where
  // Filter for special methods that aren't abstract
  functionObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(functionObj) and
  alwaysRaisesException(functionObj, exceptionClass) and
  // Exclude NotImplementedError as it's a special case
  not exceptionClass.getName() = "NotImplementedError" and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(functionObj.getName(), suggestionMessage)
    or
    // Check for incorrect exception types
    (
      not isCorrectExceptionType(functionObj.getName(), exceptionClass) and
      exists(ClassObject preferredException | 
        isPreferredExceptionType(functionObj.getName(), preferredException) |
        suggestionMessage = "raise " + preferredException.getName() + " instead"
      )
    )
  )
select functionObj, "Function always raises $@; " + suggestionMessage, exceptionClass, exceptionClass.toString()