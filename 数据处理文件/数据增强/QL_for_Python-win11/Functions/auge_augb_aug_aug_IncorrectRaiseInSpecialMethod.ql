/**
 * @name Non-standard exception raised in special method
 * @description Special methods raising non-standard exceptions violate their expected interface contracts.
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

// Helper predicates to categorize special methods
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

// Validates exception type compatibility for special methods
predicate isCorrectExceptionType(string methodNameStr, ClassObject exceptionType) {
  // Handle TypeError compatibility for specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or 
    methodNameStr = "__deepcopy__" or 
    methodNameStr = "__call__" or 
    isIndexingMethod(methodNameStr) or 
    isAttributeMethod(methodNameStr)
  )
  or
  // Check preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionType)
  or
  // Allow parent exception types
  isPreferredExceptionType(methodNameStr, exceptionType.getASuperType())
}

// Maps special methods to their preferred exception types
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

// Identifies unnecessary exception raising cases
predicate isUnnecessaryRaise(string methodNameStr, string suggestionMsg) {
  // Hash method should use __hash__ = None
  methodNameStr = "__hash__" and suggestionMsg = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodNameStr) and suggestionMsg = "there is no need to implement the method at all."
}

// Detects abstract functions through decorators
predicate isAbstractFunction(FunctionObject funcObj) {
  funcObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Checks if function always raises a specific exception type
predicate alwaysRaisesException(FunctionObject funcObj, ClassObject exceptionType) {
  exceptionType = funcObj.getARaisedType() and
  strictcount(funcObj.getARaisedType()) = 1 and
  not exists(funcObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not exceptionType = theStopIterationType()
}

// Main detection logic for non-standard exceptions in special methods
from FunctionObject funcObj, ClassObject exceptionType, string suggestionMsg
where
  // Focus on non-abstract special methods
  funcObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(funcObj) and
  alwaysRaisesException(funcObj, exceptionType) and
  (
    // Handle unnecessary exception cases
    isUnnecessaryRaise(funcObj.getName(), suggestionMsg) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Handle incorrect exception type cases
    not isCorrectExceptionType(funcObj.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(funcObj.getName(), preferredException) |
      suggestionMsg = "raise " + preferredException.getName() + " instead"
    )
  )
select funcObj, "Function always raises $@; " + suggestionMsg, exceptionType, exceptionType.toString()