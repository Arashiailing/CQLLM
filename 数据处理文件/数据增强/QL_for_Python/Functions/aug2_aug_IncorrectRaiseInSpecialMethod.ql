/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, violating expected interface contracts.
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

// Helper predicate: Identifies special methods handling attribute access
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Helper predicate: Identifies special methods handling container indexing
private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Helper predicate: Identifies special methods implementing arithmetic operations
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

// Helper predicate: Identifies special methods implementing ordering comparisons
private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

// Helper predicate: Identifies special methods implementing type conversions
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Validates if the raised exception type is appropriate for the special method
predicate isCorrectExceptionType(string methodName, ClassObject raisedException) {
  // Check for TypeError compatibility with specific method categories
  raisedException.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isIndexingMethod(methodName) or 
    isAttributeMethod(methodName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodName, raisedException)
  or
  // Check against parent exception types
  isPreferredExceptionType(methodName, raisedException.getASuperType())
}

// Determines preferred exception types for special method categories
predicate isPreferredExceptionType(string methodName, ClassObject preferredException) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and preferredException = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and preferredException = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodName) and preferredException = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and preferredException = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and preferredException = theTypeErrorType()
}

// Identifies special methods where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodName, string suggestionMessage) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestionMessage = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and suggestionMessage = "there is no need to implement the method at all."
}

// Detects abstract functions using decorators
predicate isAbstractFunction(FunctionObject specialMethod) {
  // Check for decorators containing "abstract"
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that exclusively raise a specific exception
predicate alwaysRaisesException(FunctionObject specialMethod, ClassObject raisedException) {
  // Function raises exactly one exception type with no normal exits
  raisedException = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not raisedException = theStopIterationType()
}

// Main query: Identifies special methods with non-standard exception handling
from FunctionObject specialMethod, ClassObject raisedException, string suggestionMessage
where
  // Focus on non-abstract special methods
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, raisedException) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(specialMethod.getName(), suggestionMessage) and 
    not raisedException.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(specialMethod.getName(), raisedException) and
    not raisedException.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(specialMethod.getName(), preferredException) |
      suggestionMessage = "raise " + preferredException.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestionMessage, raisedException, raisedException.toString()