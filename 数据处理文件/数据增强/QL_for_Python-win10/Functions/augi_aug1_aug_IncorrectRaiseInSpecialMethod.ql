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

// Helper predicates to identify special method categories
private predicate isAttributeRelatedMethod(string methodName) {
  methodName in ["__getattribute__", "__getattr__", "__setattr__"]
}

private predicate isIndexingRelatedMethod(string methodName) {
  methodName in ["__getitem__", "__setitem__", "__delitem__"]
}

private predicate isArithmeticRelatedMethod(string methodName) {
  methodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

private predicate isOrderingRelatedMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

private predicate isCastRelatedMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName in ["__int__", "__float__", "__long__", "__trunc__", "__complex__"]
}

// Determines if an exception type is appropriate for a given special method
predicate isValidExceptionForMethod(string methodName, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName in ["__copy__", "__deepcopy__", "__call__"] or 
    isIndexingRelatedMethod(methodName) or 
    isAttributeRelatedMethod(methodName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodName, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionType(methodName, exceptionType.getASuperType())
}

// Identifies preferred exception types for special methods
predicate isPreferredExceptionType(string methodName, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeRelatedMethod(methodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingRelatedMethod(methodName) and exceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingRelatedMethod(methodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticRelatedMethod(methodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Identifies cases where exception raising is unnecessary
predicate hasUnnecessaryRaise(string methodName, string suggestionMessage) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestionMessage = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastRelatedMethod(methodName) and suggestionMessage = "there is no need to implement the method at all."
}

// Identifies abstract functions
predicate isAbstractMethod(FunctionObject methodObj) {
  // Check for decorators containing "abstract"
  methodObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that always raise a specific exception
predicate exclusivelyRaisesException(FunctionObject methodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = methodObj.getARaisedType() and
  strictcount(methodObj.getARaisedType()) = 1 and
  not exists(methodObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query to identify special methods with non-standard exception handling
from FunctionObject specialMethod, ClassObject raisedException, string suggestionMessage
where
  // Filter for special methods that aren't abstract
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractMethod(specialMethod) and
  exclusivelyRaisesException(specialMethod, raisedException) and
  // Exclude NotImplementedError as it's a special case
  not raisedException.getName() = "NotImplementedError" and
  (
    // Check for unnecessary exception cases
    hasUnnecessaryRaise(specialMethod.getName(), suggestionMessage)
    or
    // Check for incorrect exception types
    (
      not isValidExceptionForMethod(specialMethod.getName(), raisedException) and
      exists(ClassObject preferredException | 
        isPreferredExceptionType(specialMethod.getName(), preferredException) |
        suggestionMessage = "raise " + preferredException.getName() + " instead"
      )
    )
  )
select specialMethod, "Function always raises $@; " + suggestionMessage, raisedException, raisedException.toString()