/**
 * @name Non-standard exception raised in special method
 * @description Detects when special methods raise exceptions that don't conform to Python's expected interface patterns.
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
  methodName = "__lt__" or
  methodName = "__le__" or
  methodName = "__gt__" or
  methodName = "__ge__" or
  (methodName = "__cmp__" and major_version() = 2)
}

// Helper predicate to identify type conversion special methods
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2) or
  methodName = "__int__" or
  methodName = "__float__" or
  methodName = "__long__" or
  methodName = "__trunc__" or
  methodName = "__complex__"
}

// Predicate defining preferred exception types for special methods
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

// Predicate to determine if exception type is appropriate for special method
predicate isValidExceptionType(string methodName, ClassObject exceptionType) {
  // Valid cases for TypeError
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
  // Check parent types against preferred exceptions
  isPreferredExceptionType(methodName, exceptionType.getASuperType())
}

// Predicate for cases where raising exception is unnecessary
predicate isUnnecessaryRaise(string methodName, string suggestion) {
  // Special case for __hash__ method
  methodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods may not need implementation
  isCastMethod(methodName) and suggestion = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject func) {
  exists(Name decoratorNode |
    decoratorNode = func.getFunction().getADecorator() and
    decoratorNode.getId().matches("%abstract%")
  )
}

// Predicate to identify functions that always raise specific exceptions
predicate alwaysRaisesException(FunctionObject func, ClassObject exceptionType) {
  exceptionType = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  not exists(func.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query selecting special methods with non-standard exception handling
from FunctionObject specialMethod, ClassObject raisedException, string suggestion
where
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, raisedException) and
  (
    // Case 1: Unnecessary raise with recommendation
    isUnnecessaryRaise(specialMethod.getName(), suggestion) and 
    not raisedException.getName() = "NotImplementedError"
    or
    // Case 2: Invalid exception type with alternative suggestion
    not isValidExceptionType(specialMethod.getName(), raisedException) and
    not raisedException.getName() = "NotImplementedError" and
    exists(ClassObject preferredExceptionType | 
      isPreferredExceptionType(specialMethod.getName(), preferredExceptionType) |
      suggestion = "raise " + preferredExceptionType.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestion, raisedException, raisedException.toString()