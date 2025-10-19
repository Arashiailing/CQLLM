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

// Predicate to identify attribute-related special methods
private predicate isAttributeMethod(string specialMethodName) {
  specialMethodName = "__getattribute__" or 
  specialMethodName = "__getattr__" or 
  specialMethodName = "__setattr__"
}

// Predicate to identify indexing-related special methods
private predicate isIndexingMethod(string specialMethodName) {
  specialMethodName = "__getitem__" or 
  specialMethodName = "__setitem__" or 
  specialMethodName = "__delitem__"
}

// Predicate to identify arithmetic operation special methods
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

// Predicate to identify ordering comparison special methods
private predicate isOrderingMethod(string specialMethodName) {
  (specialMethodName = "__lt__" or 
   specialMethodName = "__le__" or 
   specialMethodName = "__gt__" or 
   specialMethodName = "__ge__")
  or
  (specialMethodName = "__cmp__" and major_version() = 2)
}

// Predicate to identify type conversion special methods
private predicate isCastMethod(string specialMethodName) {
  (specialMethodName = "__nonzero__" and major_version() = 2)
  or
  specialMethodName = "__int__" or 
  specialMethodName = "__float__" or 
  specialMethodName = "__long__" or 
  specialMethodName = "__trunc__" or 
  specialMethodName = "__complex__"
}

// Predicate to determine if exception type is appropriate for special method
predicate isValidExceptionType(string specialMethodName, ClassObject exceptionClass) {
  // Valid TypeError cases for specific method categories
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or
    specialMethodName = "__deepcopy__" or
    specialMethodName = "__call__" or
    isIndexingMethod(specialMethodName) or
    isAttributeMethod(specialMethodName)
  )
  or
  // Check against preferred exception types
  isPreferredException(specialMethodName, exceptionClass)
  or
  // Check parent types against preferred exceptions
  isPreferredException(specialMethodName, exceptionClass.getASuperType())
}

// Predicate to identify preferred exception types for special methods
predicate isPreferredException(string specialMethodName, ClassObject exceptionClass) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(specialMethodName) and exceptionClass = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(specialMethodName) and exceptionClass = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(specialMethodName) and exceptionClass = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(specialMethodName) and exceptionClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  specialMethodName = "__bool__" and exceptionClass = theTypeErrorType()
}

// Predicate to identify cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string specialMethodName, string fixRecommendation) {
  // __hash__ methods should use __hash__ = None instead
  specialMethodName = "__hash__" and fixRecommendation = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(specialMethodName) and fixRecommendation = "there is no need to implement the method at all."
}

// Predicate to identify abstract functions
predicate isAbstractFunction(FunctionObject functionObj) {
  // Check for abstract decorator
  functionObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Predicate to identify functions that always raise a specific exception
predicate consistentlyRaises(FunctionObject functionObj, ClassObject exceptionClass) {
  // Function raises only this exception type
  exceptionClass = functionObj.getARaisedType() and
  strictcount(functionObj.getARaisedType()) = 1 and
  // No normal exit paths
  not exists(functionObj.getFunction().getANormalExit()) and
  // Exclude StopIteration (equivalent to return in generators)
  not exceptionClass = theStopIterationType()
}

// Main query to detect non-standard exceptions in special methods
from FunctionObject specialMethod, ClassObject raisedException, string fixRecommendation
where
  // Target special methods that aren't abstract
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  consistentlyRaises(specialMethod, raisedException) and
  (
    // Case 1: Unnecessary exception raising
    isUnnecessaryRaise(specialMethod.getName(), fixRecommendation) and 
    not raisedException.getName() = "NotImplementedError"
    or
    // Case 2: Incorrect exception type with recommended alternative
    not isValidExceptionType(specialMethod.getName(), raisedException) and
    not raisedException.getName() = "NotImplementedError" and
    exists(ClassObject preferredExceptionType | 
      isPreferredException(specialMethod.getName(), preferredExceptionType) |
      fixRecommendation = "raise " + preferredExceptionType.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + fixRecommendation, raisedException, raisedException.toString()