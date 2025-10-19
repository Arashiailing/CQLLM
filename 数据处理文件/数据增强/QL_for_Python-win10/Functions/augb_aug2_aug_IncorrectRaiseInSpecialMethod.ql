/**
 * @name Non-standard exception in special method
 * @description Identifies special methods that raise exceptions which do not conform to the expected interface contracts.
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

// Helper predicate: Identifies special methods that handle attribute access
private predicate isAttributeMethod(string specialMethodName) {
  specialMethodName = "__getattribute__" or 
  specialMethodName = "__getattr__" or 
  specialMethodName = "__setattr__"
}

// Helper predicate: Identifies special methods that handle container indexing
private predicate isIndexingMethod(string specialMethodName) {
  specialMethodName = "__getitem__" or 
  specialMethodName = "__setitem__" or 
  specialMethodName = "__delitem__"
}

// Helper predicate: Identifies special methods that implement arithmetic operations
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

// Helper predicate: Identifies special methods that implement ordering comparisons
private predicate isOrderingMethod(string specialMethodName) {
  (specialMethodName = "__lt__" or 
   specialMethodName = "__le__" or 
   specialMethodName = "__gt__" or 
   specialMethodName = "__ge__") 
  or 
  (specialMethodName = "__cmp__" and major_version() = 2)
}

// Helper predicate: Identifies special methods that implement type conversions
private predicate isCastMethod(string specialMethodName) {
  (specialMethodName = "__nonzero__" and major_version() = 2)
  or
  specialMethodName = "__int__" or 
  specialMethodName = "__float__" or 
  specialMethodName = "__long__" or 
  specialMethodName = "__trunc__" or 
  specialMethodName = "__complex__"
}

// Determines the preferred exception types for different categories of special methods
predicate isPreferredExceptionType(string specialMethodName, ClassObject preferredExceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(specialMethodName) and preferredExceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(specialMethodName) and preferredExceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(specialMethodName) and preferredExceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(specialMethodName) and preferredExceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  specialMethodName = "__bool__" and preferredExceptionType = theTypeErrorType()
}

// Validates whether the raised exception type is appropriate for the special method
predicate isCorrectExceptionType(string specialMethodName, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or 
    specialMethodName = "__deepcopy__" or 
    specialMethodName = "__call__" or 
    isIndexingMethod(specialMethodName) or 
    isAttributeMethod(specialMethodName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(specialMethodName, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionType(specialMethodName, exceptionType.getASuperType())
}

// Identifies special methods where raising an exception is unnecessary
predicate isUnnecessaryRaise(string specialMethodName, string suggestionText) {
  // Hash method should use __hash__ = None instead
  specialMethodName = "__hash__" and suggestionText = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(specialMethodName) and suggestionText = "there is no need to implement the method at all."
}

// Detects functions that are abstract based on their decorators
predicate isAbstractFunction(FunctionObject methodObj) {
  // Check for decorators containing "abstract"
  methodObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that exclusively raise a specific exception type
predicate alwaysRaisesException(FunctionObject methodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = methodObj.getARaisedType() and
  strictcount(methodObj.getARaisedType()) = 1 and
  not exists(methodObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query: Identifies special methods with non-standard exception handling
from FunctionObject methodObj, ClassObject exceptionType, string suggestionText
where
  // Focus on non-abstract special methods
  methodObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(methodObj) and
  alwaysRaisesException(methodObj, exceptionType) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(methodObj.getName(), suggestionText) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(methodObj.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredExceptionType | 
      isPreferredExceptionType(methodObj.getName(), preferredExceptionType) |
      suggestionText = "raise " + preferredExceptionType.getName() + " instead"
    )
  )
select methodObj, "Function always raises $@; " + suggestionText, exceptionType, exceptionType.toString()