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
private predicate isAttributeMethod(string specialMethodName) {
  specialMethodName = "__getattribute__" or 
  specialMethodName = "__getattr__" or 
  specialMethodName = "__setattr__"
}

// Helper predicate to identify indexing-related special methods
private predicate isIndexingMethod(string specialMethodName) {
  specialMethodName = "__getitem__" or 
  specialMethodName = "__setitem__" or 
  specialMethodName = "__delitem__"
}

// Helper predicate to identify arithmetic operation special methods
private predicate isArithmeticMethod(string specialMethodName) {
  specialMethodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Helper predicate to identify ordering comparison special methods
private predicate isOrderingMethod(string specialMethodName) {
  specialMethodName = "__lt__" or
  specialMethodName = "__le__" or
  specialMethodName = "__gt__" or
  specialMethodName = "__ge__" or
  (specialMethodName = "__cmp__" and major_version() = 2)
}

// Helper predicate to identify type conversion special methods
private predicate isCastMethod(string specialMethodName) {
  (specialMethodName = "__nonzero__" and major_version() = 2) or
  specialMethodName = "__int__" or
  specialMethodName = "__float__" or
  specialMethodName = "__long__" or
  specialMethodName = "__trunc__" or
  specialMethodName = "__complex__"
}

// Predicate defining preferred exception types for special methods
predicate isPreferredExceptionType(string specialMethodName, ClassObject raisedException) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(specialMethodName) and raisedException = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(specialMethodName) and raisedException = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(specialMethodName) and raisedException = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(specialMethodName) and raisedException = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  specialMethodName = "__bool__" and raisedException = theTypeErrorType()
}

// Predicate to determine if exception type is appropriate for special method
predicate isValidExceptionType(string specialMethodName, ClassObject raisedException) {
  // Valid cases for TypeError
  raisedException.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or
    specialMethodName = "__deepcopy__" or
    specialMethodName = "__call__" or
    isIndexingMethod(specialMethodName) or
    isAttributeMethod(specialMethodName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(specialMethodName, raisedException)
  or
  // Check parent types against preferred exceptions
  isPreferredExceptionType(specialMethodName, raisedException.getASuperType())
}

// Predicate for cases where raising exception is unnecessary
predicate isUnnecessaryRaise(string specialMethodName, string recommendationMsg) {
  // Special case for __hash__ method
  specialMethodName = "__hash__" and recommendationMsg = "use __hash__ = None instead"
  or
  // Cast methods may not need implementation
  isCastMethod(specialMethodName) and recommendationMsg = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject method) {
  exists(Name decoratorNode |
    decoratorNode = method.getFunction().getADecorator() and
    decoratorNode.getId().matches("%abstract%")
  )
}

// Predicate to identify functions that always raise specific exceptions
predicate alwaysRaisesException(FunctionObject method, ClassObject raisedException) {
  raisedException = method.getARaisedType() and
  strictcount(method.getARaisedType()) = 1 and
  not exists(method.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not raisedException = theStopIterationType()
}

// Main query selecting special methods with non-standard exception handling
from FunctionObject method, ClassObject exceptionClass, string recommendationMsg
where
  method.getFunction().isSpecialMethod() and
  not isAbstractFunction(method) and
  alwaysRaisesException(method, exceptionClass) and
  (
    // Case 1: Unnecessary raise with recommendation
    isUnnecessaryRaise(method.getName(), recommendationMsg) and 
    not exceptionClass.getName() = "NotImplementedError"
    or
    // Case 2: Invalid exception type with alternative suggestion
    not isValidExceptionType(method.getName(), exceptionClass) and
    not exceptionClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredType | 
      isPreferredExceptionType(method.getName(), preferredType) |
      recommendationMsg = "raise " + preferredType.getName() + " instead"
    )
  )
select method, "Function always raises $@; " + recommendationMsg, exceptionClass, exceptionClass.toString()