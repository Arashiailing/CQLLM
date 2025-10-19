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

// Special method categorization helpers
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

// Exception type compatibility validation
predicate isCorrectExceptionType(string specialMethodName, ClassObject raisedException) {
  // TypeError compatibility for specific method categories
  raisedException.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or 
    specialMethodName = "__deepcopy__" or 
    specialMethodName = "__call__" or 
    isIndexingMethod(specialMethodName) or 
    isAttributeMethod(specialMethodName)
  )
  or
  // Preferred exception type validation
  isPreferredExceptionType(specialMethodName, raisedException)
  or
  // Parent exception type validation
  isPreferredExceptionType(specialMethodName, raisedException.getASuperType())
}

// Preferred exception type mappings
predicate isPreferredExceptionType(string specialMethodName, ClassObject raisedException) {
  // Attribute methods require AttributeError
  isAttributeMethod(specialMethodName) and raisedException = theAttributeErrorType()
  or
  // Indexing methods require LookupError
  isIndexingMethod(specialMethodName) and raisedException = Object::builtin("LookupError")
  or
  // Ordering methods require TypeError
  isOrderingMethod(specialMethodName) and raisedException = theTypeErrorType()
  or
  // Arithmetic methods require ArithmeticError
  isArithmeticMethod(specialMethodName) and raisedException = Object::builtin("ArithmeticError")
  or
  // __bool__ method requires TypeError
  specialMethodName = "__bool__" and raisedException = theTypeErrorType()
}

// Unnecessary exception handling cases
predicate isUnnecessaryRaise(string specialMethodName, string suggestion) {
  // Hash method should use __hash__ = None
  specialMethodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(specialMethodName) and suggestion = "there is no need to implement the method at all."
}

// Function behavior analysis
predicate isAbstractFunction(FunctionObject specialMethod) {
  // Detect abstract method decorators
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject specialMethod, ClassObject raisedException) {
  // Function raises exactly one exception type with no normal exits
  raisedException = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not raisedException = theStopIterationType()
}

// Main detection logic
from FunctionObject specialMethod, ClassObject raisedException, string suggestion
where
  // Target non-abstract special methods
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, raisedException) and
  (
    // Unnecessary exception cases
    isUnnecessaryRaise(specialMethod.getName(), suggestion) and 
    not raisedException.getName() = "NotImplementedError"
    or
    // Incorrect exception type cases
    not isCorrectExceptionType(specialMethod.getName(), raisedException) and
    not raisedException.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(specialMethod.getName(), preferredException) |
      suggestion = "raise " + preferredException.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestion, raisedException, raisedException.toString()