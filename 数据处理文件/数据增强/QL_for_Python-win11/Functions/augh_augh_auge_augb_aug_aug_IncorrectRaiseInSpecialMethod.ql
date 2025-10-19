/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, violating their expected interface contracts.
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

// Helper predicates to categorize special methods by their functionality
private predicate isAttributeMethod(string specialMethodName) {
  specialMethodName = "__getattribute__" or 
  specialMethodName = "__getattr__" or 
  specialMethodName = "__setattr__"
}

private predicate isIndexingMethod(string specialMethodName) {
  specialMethodName = "__getitem__" or 
  specialMethodName = "__setitem__" or 
  specialMethodName = "__delitem__"
}

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

private predicate isOrderingMethod(string specialMethodName) {
  (specialMethodName = "__lt__" or 
   specialMethodName = "__le__" or 
   specialMethodName = "__gt__" or 
   specialMethodName = "__ge__") 
  or 
  (specialMethodName = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string specialMethodName) {
  (specialMethodName = "__nonzero__" and major_version() = 2)
  or
  specialMethodName = "__int__" or 
  specialMethodName = "__float__" or 
  specialMethodName = "__long__" or 
  specialMethodName = "__trunc__" or 
  specialMethodName = "__complex__"
}

// Maps special methods to their preferred exception types based on their functionality
predicate isPreferredExceptionType(string specialMethodName, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(specialMethodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(specialMethodName) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(specialMethodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(specialMethodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  specialMethodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Validates exception type compatibility for special methods
predicate isCorrectExceptionType(string specialMethodName, ClassObject exceptionType) {
  // Handle TypeError compatibility for specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or 
    specialMethodName = "__deepcopy__" or 
    specialMethodName = "__call__" or 
    isIndexingMethod(specialMethodName) or 
    isAttributeMethod(specialMethodName)
  )
  or
  // Check preferred exception types
  isPreferredExceptionType(specialMethodName, exceptionType)
  or
  // Allow parent exception types
  isPreferredExceptionType(specialMethodName, exceptionType.getASuperType())
}

// Identifies unnecessary exception raising cases
predicate isUnnecessaryRaise(string specialMethodName, string recommendation) {
  // Hash method should use __hash__ = None
  specialMethodName = "__hash__" and recommendation = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(specialMethodName) and recommendation = "there is no need to implement the method at all."
}

// Detects abstract functions through decorators
predicate isAbstractFunction(FunctionObject specialMethod) {
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Checks if function always raises a specific exception type
predicate alwaysRaisesException(FunctionObject specialMethod, ClassObject exceptionType) {
  exceptionType = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not exceptionType = theStopIterationType()
}

// Main detection logic for non-standard exceptions in special methods
from FunctionObject specialMethod, ClassObject exceptionType, string recommendation
where
  // Focus on non-abstract special methods
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, exceptionType) and
  (
    // Handle unnecessary exception cases
    isUnnecessaryRaise(specialMethod.getName(), recommendation) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Handle incorrect exception type cases
    not isCorrectExceptionType(specialMethod.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredExceptionType | 
      isPreferredExceptionType(specialMethod.getName(), preferredExceptionType) |
      recommendation = "raise " + preferredExceptionType.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + recommendation, exceptionType, exceptionType.toString()