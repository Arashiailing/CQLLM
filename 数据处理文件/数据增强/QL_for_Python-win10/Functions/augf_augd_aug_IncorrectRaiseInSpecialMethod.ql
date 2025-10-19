/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, which can alter their expected interface.
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

// Determines if the raised exception type is appropriate for the special method
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

// Determines preferred exception types for special methods
predicate isPreferredExceptionType(string methodName, ClassObject raisedException) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and raisedException = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and raisedException = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodName) and raisedException = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and raisedException = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and raisedException = theTypeErrorType()
}

// Identifies cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodName, string recommendedAction) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and recommendedAction = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and recommendedAction = "there is no need to implement the method at all."
}

// Identifies abstract functions by checking for decorators containing "abstract"
predicate isAbstractFunction(FunctionObject targetMethod) {
  targetMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that always raise a specific exception with no normal exits
predicate alwaysRaisesException(FunctionObject targetMethod, ClassObject raisedException) {
  raisedException = targetMethod.getARaisedType() and
  strictcount(targetMethod.getARaisedType()) = 1 and
  not exists(targetMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not raisedException = theStopIterationType()
}

// Main query to identify special methods with non-standard exception handling
from FunctionObject targetMethod, ClassObject raisedExceptionClass, string recommendedAction
where
  // Filter for special methods that aren't abstract
  targetMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(targetMethod) and
  alwaysRaisesException(targetMethod, raisedExceptionClass) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(targetMethod.getName(), recommendedAction) and 
    not raisedExceptionClass.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(targetMethod.getName(), raisedExceptionClass) and
    not raisedExceptionClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(targetMethod.getName(), preferredException) |
      recommendedAction = "raise " + preferredException.getName() + " instead"
    )
  )
select targetMethod, "Function always raises $@; " + recommendedAction, raisedExceptionClass, raisedExceptionClass.toString()