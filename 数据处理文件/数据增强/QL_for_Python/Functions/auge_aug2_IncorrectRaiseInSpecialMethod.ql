/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, 
 *              which violates their expected interface and may cause unexpected behavior.
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
private predicate isAttributeMethod(string methodIdentifier) {
  methodIdentifier = ["__getattribute__", "__getattr__", "__setattr__"]
}

// Helper predicate to identify indexing-related special methods
private predicate isIndexingMethod(string methodIdentifier) {
  methodIdentifier = ["__getitem__", "__setitem__", "__delitem__"]
}

// Helper predicate to identify arithmetic operation special methods
private predicate isArithmeticMethod(string methodIdentifier) {
  methodIdentifier in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Helper predicate to identify ordering comparison special methods
private predicate isOrderingMethod(string methodIdentifier) {
  methodIdentifier = ["__lt__", "__le__", "__gt__", "__ge__"] or
  (methodIdentifier = "__cmp__" and major_version() = 2)
}

// Helper predicate to identify type conversion special methods
private predicate isCastMethod(string methodIdentifier) {
  (methodIdentifier = "__nonzero__" and major_version() = 2) or
  methodIdentifier = ["__int__", "__float__", "__long__", "__trunc__", "__complex__"]
}

// Predicate to determine if exception type is appropriate for special method
predicate isValidExceptionType(string methodIdentifier, ClassObject exceptionClass) {
  // Valid cases for TypeError
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodIdentifier = ["__copy__", "__deepcopy__", "__call__"] or
    isIndexingMethod(methodIdentifier) or
    isAttributeMethod(methodIdentifier)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodIdentifier, exceptionClass)
  or
  // Check parent types against preferred exceptions
  isPreferredExceptionType(methodIdentifier, exceptionClass.getASuperType())
}

// Predicate defining preferred exception types for special methods
predicate isPreferredExceptionType(string methodIdentifier, ClassObject exceptionClass) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodIdentifier) and exceptionClass = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodIdentifier) and exceptionClass = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodIdentifier) and exceptionClass = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodIdentifier) and exceptionClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodIdentifier = "__bool__" and exceptionClass = theTypeErrorType()
}

// Predicate for cases where raising exception is unnecessary
predicate isUnnecessaryRaise(string methodIdentifier, string recommendation) {
  // Special case for __hash__ method
  methodIdentifier = "__hash__" and recommendation = "use __hash__ = None instead"
  or
  // Cast methods may not need implementation
  isCastMethod(methodIdentifier) and recommendation = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject methodFunction) {
  exists(Name decorator |
    decorator = methodFunction.getFunction().getADecorator() and
    decorator.getId().matches("%abstract%")
  )
}

// Predicate to identify functions that always raise specific exceptions
predicate alwaysRaisesException(FunctionObject methodFunction, ClassObject exceptionClass) {
  exceptionClass = methodFunction.getARaisedType() and
  strictcount(methodFunction.getARaisedType()) = 1 and
  not exists(methodFunction.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionClass = theStopIterationType()
}

// Main query selecting special methods with non-standard exception handling
from FunctionObject f, ClassObject cls, string message
where
  f.getFunction().isSpecialMethod() and
  not isAbstractFunction(f) and
  alwaysRaisesException(f, cls) and
  (
    // Case 1: Unnecessary raise with recommendation
    isUnnecessaryRaise(f.getName(), message) and 
    not cls.getName() = "NotImplementedError"
    or
    // Case 2: Invalid exception type with alternative suggestion
    not isValidExceptionType(f.getName(), cls) and
    not cls.getName() = "NotImplementedError" and
    exists(ClassObject preferredType | 
      isPreferredExceptionType(f.getName(), preferredType) |
      message = "raise " + preferredType.getName() + " instead"
    )
  )
select f, "Function always raises $@; " + message, cls, cls.toString()