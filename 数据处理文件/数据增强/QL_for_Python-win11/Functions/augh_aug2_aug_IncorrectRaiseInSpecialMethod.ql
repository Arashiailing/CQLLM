/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, violating expected interface contracts.
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

// Helper predicates for identifying categories of special methods
private predicate handlesAttributeAccess(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

private predicate handlesContainerIndexing(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

private predicate implementsArithmeticOperation(string methodName) {
  methodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

private predicate implementsOrderingComparison(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

private predicate implementsTypeConversion(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Validates if the raised exception type is appropriate for the special method
predicate isValidExceptionTypeForMethod(string methodName, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    handlesContainerIndexing(methodName) or 
    handlesAttributeAccess(methodName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionForMethod(methodName, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionForMethod(methodName, exceptionType.getASuperType())
}

// Determines preferred exception types for special method categories
predicate isPreferredExceptionForMethod(string methodName, ClassObject preferredException) {
  // Attribute methods should raise AttributeError
  handlesAttributeAccess(methodName) and preferredException = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  handlesContainerIndexing(methodName) and preferredException = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  implementsOrderingComparison(methodName) and preferredException = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  implementsArithmeticOperation(methodName) and preferredException = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and preferredException = theTypeErrorType()
}

// Identifies special methods where exception raising is unnecessary
predicate shouldAvoidRaisingException(string methodName, string suggestion) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  implementsTypeConversion(methodName) and suggestion = "there is no need to implement the method at all."
}

// Detects abstract functions using decorators
predicate isAbstractMethod(FunctionObject specialMethod) {
  // Check for decorators containing "abstract"
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that exclusively raise a specific exception
predicate raisesOnlyException(FunctionObject specialMethod, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query: Identifies special methods with non-standard exception handling
from FunctionObject specialMethod, ClassObject exceptionType, string suggestionMessage
where
  // Focus on non-abstract special methods
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractMethod(specialMethod) and
  raisesOnlyException(specialMethod, exceptionType) and
  (
    // Check for unnecessary exception cases
    shouldAvoidRaisingException(specialMethod.getName(), suggestionMessage) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isValidExceptionTypeForMethod(specialMethod.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionForMethod(specialMethod.getName(), preferredException) |
      suggestionMessage = "raise " + preferredException.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestionMessage, exceptionType, exceptionType.toString()