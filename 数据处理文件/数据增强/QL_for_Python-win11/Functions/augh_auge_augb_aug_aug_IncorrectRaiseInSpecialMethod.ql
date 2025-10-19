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
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

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

private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Maps special methods to their preferred exception types
predicate isPreferredExceptionType(string methodName, ClassObject exType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and exType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and exType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodName) and exType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and exType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and exType = theTypeErrorType()
}

// Validates exception type compatibility for special methods
predicate isCorrectExceptionType(string methodName, ClassObject exType) {
  // Handle TypeError compatibility for specific method categories
  exType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isIndexingMethod(methodName) or 
    isAttributeMethod(methodName)
  )
  or
  // Check preferred exception types
  isPreferredExceptionType(methodName, exType)
  or
  // Allow parent exception types
  isPreferredExceptionType(methodName, exType.getASuperType())
}

// Identifies unnecessary exception raising cases
predicate isUnnecessaryRaise(string methodName, string suggestion) {
  // Hash method should use __hash__ = None
  methodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and suggestion = "there is no need to implement the method at all."
}

// Detects abstract functions through decorators
predicate isAbstractFunction(FunctionObject func) {
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Checks if function always raises a specific exception type
predicate alwaysRaisesException(FunctionObject func, ClassObject exType) {
  exType = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  not exists(func.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not exType = theStopIterationType()
}

// Main detection logic for non-standard exceptions in special methods
from FunctionObject func, ClassObject exType, string suggestion
where
  // Focus on non-abstract special methods
  func.getFunction().isSpecialMethod() and
  not isAbstractFunction(func) and
  alwaysRaisesException(func, exType) and
  (
    // Handle unnecessary exception cases
    isUnnecessaryRaise(func.getName(), suggestion) and 
    not exType.getName() = "NotImplementedError"
    or
    // Handle incorrect exception type cases
    not isCorrectExceptionType(func.getName(), exType) and
    not exType.getName() = "NotImplementedError" and
    exists(ClassObject preferredExType | 
      isPreferredExceptionType(func.getName(), preferredExType) |
      suggestion = "raise " + preferredExType.getName() + " instead"
    )
  )
select func, "Function always raises $@; " + suggestion, exType, exType.toString()