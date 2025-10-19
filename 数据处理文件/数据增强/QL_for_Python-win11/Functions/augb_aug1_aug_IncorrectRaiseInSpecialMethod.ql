/**
 * @name Non-standard exception raised in special method
 * @description Special methods should raise only standard exceptions to maintain expected interface behavior.
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

// Category 1: Attribute access special methods
private predicate isAttributeAccessMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Category 2: Container indexing special methods
private predicate isContainerIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Category 3: Arithmetic operation special methods
private predicate isArithmeticOperationMethod(string methodName) {
  methodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Category 4: Comparison operation special methods
private predicate isComparisonOperationMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__") 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

// Category 5: Type conversion special methods
private predicate isTypeConversionMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Validates if the raised exception type is appropriate for the special method
predicate isValidExceptionTypeForMethod(string methodName, ClassObject raisedException) {
  // Special case: TypeError is acceptable for certain method categories
  raisedException.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or 
    methodName = "__deepcopy__" or 
    methodName = "__call__" or 
    isContainerIndexingMethod(methodName) or 
    isAttributeAccessMethod(methodName)
  )
  or
  // Check if the exception matches the preferred type for the method
  isPreferredExceptionForMethod(methodName, raisedException)
  or
  // Check if the exception is a subclass of the preferred type
  exists(ClassObject preferredType |
    isPreferredExceptionForMethod(methodName, preferredType) and
    raisedException.getASuperType() = preferredType
  )
}

// Defines the preferred exception types for different special method categories
predicate isPreferredExceptionForMethod(string methodName, ClassObject preferredException) {
  // Attribute access methods should raise AttributeError
  isAttributeAccessMethod(methodName) and preferredException = theAttributeErrorType()
  or
  // Container indexing methods should raise LookupError
  isContainerIndexingMethod(methodName) and preferredException = Object::builtin("LookupError")
  or
  // Comparison operation methods should raise TypeError
  isComparisonOperationMethod(methodName) and preferredException = theTypeErrorType()
  or
  // Arithmetic operation methods should raise ArithmeticError
  isArithmeticOperationMethod(methodName) and preferredException = Object::builtin("ArithmeticError")
  or
  // Boolean conversion method should raise TypeError
  methodName = "__bool__" and preferredException = theTypeErrorType()
}

// Identifies special methods where raising exceptions is unnecessary
predicate hasUnnecessaryExceptionHandling(string methodName, string remediationAdvice) {
  // Hash method should be disabled with __hash__ = None instead of raising
  methodName = "__hash__" and remediationAdvice = "use __hash__ = None instead"
  or
  // Type conversion methods typically don't need implementation
  isTypeConversionMethod(methodName) and remediationAdvice = "there is no need to implement the method at all."
}

// Detects functions decorated as abstract
predicate isAbstractMethod(FunctionObject methodObj) {
  // Abstract decorators typically contain "abstract" in their name
  exists(Name decorator |
    decorator = methodObj.getFunction().getADecorator() and
    decorator.getId().matches("%abstract%")
  )
}

// Identifies functions that exclusively raise a single exception type
predicate exclusivelyRaisesException(FunctionObject methodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type and has no normal exit paths
  exceptionType = methodObj.getARaisedType() and
  strictcount(methodObj.getARaisedType()) = 1 and
  not exists(methodObj.getFunction().getANormalExit()) and
  /* Special case: StopIteration is equivalent to return in generator functions */
  not exceptionType = theStopIterationType()
}

// Main query logic: Find special methods with non-standard exception handling
from FunctionObject methodObj, ClassObject raisedException, string remediationAdvice
where
  // Focus on special methods that are not abstract
  methodObj.getFunction().isSpecialMethod() and
  not isAbstractMethod(methodObj) and
  exclusivelyRaisesException(methodObj, raisedException) and
  // Exclude NotImplementedError as it has special semantics
  not raisedException.getName() = "NotImplementedError" and
  (
    // Case 1: Method has unnecessary exception handling
    hasUnnecessaryExceptionHandling(methodObj.getName(), remediationAdvice)
    or
    // Case 2: Method raises inappropriate exception type
    (
      not isValidExceptionTypeForMethod(methodObj.getName(), raisedException) and
      exists(ClassObject preferredException | 
        isPreferredExceptionForMethod(methodObj.getName(), preferredException) |
        remediationAdvice = "raise " + preferredException.getName() + " instead"
      )
    )
  )
select methodObj, "Function always raises $@; " + remediationAdvice, raisedException, raisedException.toString()