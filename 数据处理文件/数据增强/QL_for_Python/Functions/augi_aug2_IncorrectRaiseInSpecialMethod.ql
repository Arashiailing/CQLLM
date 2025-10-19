/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, which may violate expected interfaces.
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

// Helper predicates to categorize special methods by their conventional behavior
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
  methodNameStr = "__lt__" or
  methodNameStr = "__le__" or
  methodNameStr = "__gt__" or
  methodNameStr = "__ge__" or
  (methodNameStr = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string methodNameStr) {
  (methodNameStr = "__nonzero__" and major_version() = 2) or
  methodNameStr = "__int__" or
  methodNameStr = "__float__" or
  methodNameStr = "__long__" or
  methodNameStr = "__trunc__" or
  methodNameStr = "__complex__"
}

// Validates exception types against method-specific conventions
predicate isValidExceptionType(string methodNameStr, ClassObject exceptionClass) {
  // Valid cases for TypeError
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or
    methodNameStr = "__deepcopy__" or
    methodNameStr = "__call__" or
    isIndexingMethod(methodNameStr) or
    isAttributeMethod(methodNameStr)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionClass)
  or
  // Check parent types against preferred exceptions
  isPreferredExceptionType(methodNameStr, exceptionClass.getASuperType())
}

// Defines preferred exception types for special methods
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

// Identifies special methods where raising exceptions is unnecessary
predicate isUnnecessaryRaise(string methodNameStr, string recommendationStr) {
  // Special case for __hash__ method
  methodNameStr = "__hash__" and recommendationStr = "use __hash__ = None instead"
  or
  // Cast methods may not need implementation
  isCastMethod(methodNameStr) and recommendationStr = "there is no need to implement the method at all."
}

// Identifies abstract functions using decorators
predicate isAbstractFunction(FunctionObject functionObj) {
  exists(Name decorator |
    decorator = functionObj.getFunction().getADecorator() and
    decorator.getId().matches("%abstract%")
  )
}

// Detects functions that exclusively raise specific exceptions
predicate alwaysRaisesException(FunctionObject functionObj, ClassObject exceptionClass) {
  exceptionClass = functionObj.getARaisedType() and
  strictcount(functionObj.getARaisedType()) = 1 and
  not exists(functionObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionClass = theStopIterationType()
}

// Main query logic: identifies special methods with non-standard exception handling
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