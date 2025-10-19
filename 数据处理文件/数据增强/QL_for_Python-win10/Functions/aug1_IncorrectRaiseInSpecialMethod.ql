/**
 * @name Non-standard exception raised in special method
 * @description Raising a non-standard exception in a special method alters the expected interface of that method.
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

// Predicate to determine if an exception type is appropriate for a special method
predicate isValidExceptionType(string methodName, ClassObject exceptionType) {
  // Allow TypeError for specific method categories
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
  isPreferredException(methodName, exceptionType)
  or
  isPreferredException(methodName, exceptionType.getASuperType())
}

// Predicate to identify preferred exception types for special methods
predicate isPreferredException(string methodName, ClassObject exceptionType) {
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

// Predicate to identify cases where raising exceptions is unnecessary
predicate isUnnecessaryRaise(string methodName, string recommendation) {
  // Recommend __hash__ = None instead of raising
  methodName = "__hash__" and recommendation = "use __hash__ = None instead"
  or
  // Recommend not implementing cast methods
  isCastMethod(methodName) and recommendation = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject functionObj) {
  // Check for abstract decorator
  functionObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Predicate to identify functions that always raise a specific exception
predicate alwaysRaisesException(FunctionObject functionObj, ClassObject exceptionType) {
  // Function raises only one exception type
  exceptionType = functionObj.getARaisedType() and
  strictcount(functionObj.getARaisedType()) = 1 and
  // No normal exit paths
  not exists(functionObj.getFunction().getANormalExit()) and
  /* Raising StopIteration is equivalent to return in generators */
  not exceptionType = theStopIterationType()
}

// Main query to detect non-standard exceptions in special methods
from FunctionObject functionObj, ClassObject exceptionClass, string recommendation
where
  // Filter special methods that aren't abstract
  functionObj.getFunction().isSpecialMethod() and
  not isAbstractFunction(functionObj) and
  // Identify methods that always raise exceptions
  alwaysRaisesException(functionObj, exceptionClass) and
  (
    // Check for unnecessary raises
    isUnnecessaryRaise(functionObj.getName(), recommendation) and 
    not exceptionClass.getName() = "NotImplementedError"
    or
    // Check for invalid exception types
    not isValidExceptionType(functionObj.getName(), exceptionClass) and
    not exceptionClass.getName() = "NotImplementedError" and
    // Generate recommendation message
    exists(ClassObject preferredType | 
      isPreferredException(functionObj.getName(), preferredType) |
      recommendation = "raise " + preferredType.getName() + " instead"
    )
  )
select functionObj, "Function always raises $@; " + recommendation, exceptionClass, exceptionClass.toString()