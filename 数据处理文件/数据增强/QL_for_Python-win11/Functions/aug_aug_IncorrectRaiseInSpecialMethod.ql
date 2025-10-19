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

// Helper predicates for special method categorization
private predicate isAttributeMethod(string methodNameStr) {
  methodNameStr = "__getattribute__" or 
  methodNameStr = "__getattr__" or 
  methodNameStr = "__setattr__"
}

private predicate isIndexingMethod(string methodNameStr) {
  methodNameStr = "__getitem__" or 
  methodNameStr = "__setitem__" or 
  methodNameStr = "__delitem__"
}

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

private predicate isOrderingMethod(string methodNameStr) {
  (methodNameStr = "__lt__" or 
   methodNameStr = "__le__" or 
   methodNameStr = "__gt__" or 
   methodNameStr = "__ge__") 
  or 
  (methodNameStr = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string methodNameStr) {
  (methodNameStr = "__nonzero__" and major_version() = 2)
  or
  methodNameStr = "__int__" or 
  methodNameStr = "__float__" or 
  methodNameStr = "__long__" or 
  methodNameStr = "__trunc__" or 
  methodNameStr = "__complex__"
}

// Exception type validation logic
predicate isCorrectExceptionType(string methodNameStr, ClassObject exceptionClass) {
  // Validate TypeError compatibility for specific method categories
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or 
    methodNameStr = "__deepcopy__" or 
    methodNameStr = "__call__" or 
    isIndexingMethod(methodNameStr) or 
    isAttributeMethod(methodNameStr)
  )
  or
  // Validate preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionClass)
  or
  // Validate parent exception types
  isPreferredExceptionType(methodNameStr, exceptionClass.getASuperType())
}

// Preferred exception type definitions
predicate isPreferredExceptionType(string methodNameStr, ClassObject exceptionClass) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodNameStr) and exceptionClass = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodNameStr) and exceptionClass = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodNameStr) and exceptionClass = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodNameStr) and exceptionClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodNameStr = "__bool__" and exceptionClass = theTypeErrorType()
}

// Unnecessary exception handling detection
predicate isUnnecessaryRaise(string methodNameStr, string suggestionMessage) {
  // Hash method should use __hash__ = None instead
  methodNameStr = "__hash__" and suggestionMessage = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodNameStr) and suggestionMessage = "there is no need to implement the method at all."
}

// Function behavior analysis predicates
predicate isAbstractFunction(FunctionObject funcObj) {
  // Check for decorators containing "abstract"
  funcObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject funcObj, ClassObject exceptionClass) {
  // Function raises exactly one exception type with no normal exits
  exceptionClass = funcObj.getARaisedType() and
  strictcount(funcObj.getARaisedType()) = 1 and
  not exists(funcObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionClass = theStopIterationType()
}

// Main query logic
from FunctionObject functionObj, ClassObject exceptionClass, string suggestionMessage
where
  // Identify non-abstract special methods
  functionObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(functionObj) and
  alwaysRaisesException(functionObj, exceptionClass) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(functionObj.getName(), suggestionMessage) and 
    not exceptionClass.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(functionObj.getName(), exceptionClass) and
    not exceptionClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(functionObj.getName(), preferredException) |
      suggestionMessage = "raise " + preferredException.getName() + " instead"
    )
  )
select functionObj, "Function always raises $@; " + suggestionMessage, exceptionClass, exceptionClass.toString()