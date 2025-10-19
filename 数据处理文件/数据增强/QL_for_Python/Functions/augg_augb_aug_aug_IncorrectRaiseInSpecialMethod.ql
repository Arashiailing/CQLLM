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

// Helper predicates for special method categorization
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

// Validation of exception type compatibility
predicate isCorrectExceptionType(string methodNameStr, ClassObject exceptionClass) {
  // Validate TypeError compatibility for specific method categories
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or 
    methodNameStr = "__deepcopy__" or 
    methodNameStr = "__call__" or 
    isIndexingMethod(methodNameStr) or 
    isAttributeMethod(methodNameStr)
  )
  or
  // Validate preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionClass)
  or
  // Validate parent exception types
  isPreferredExceptionType(methodNameStr, exceptionClass.getASuperType())
}

// Mappings for preferred exception types
predicate isPreferredExceptionType(string methodNameStr, ClassObject exceptionClass) {
  // Attribute methods require AttributeError
  isAttributeMethod(methodNameStr) and exceptionClass = theAttributeErrorType()
  or
  // Indexing methods require LookupError
  isIndexingMethod(methodNameStr) and exceptionClass = Object::builtin("LookupError")
  or
  // Ordering methods require TypeError
  isOrderingMethod(methodNameStr) and exceptionClass = theTypeErrorType()
  or
  // Arithmetic methods require ArithmeticError
  isArithmeticMethod(methodNameStr) and exceptionClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method requires TypeError
  methodNameStr = "__bool__" and exceptionClass = theTypeErrorType()
}

// Detection of unnecessary exception handling cases
predicate isUnnecessaryRaise(string methodNameStr, string suggestion) {
  // Hash method should use __hash__ = None
  methodNameStr = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodNameStr) and suggestion = "there is no need to implement the method at all."
}

// Analysis of function behavior
predicate isAbstractFunction(FunctionObject specialMethod) {
  // Detection of abstract method decorators
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject specialMethod, ClassObject exceptionClass) {
  // Function raises exactly one exception type with no normal exits
  exceptionClass = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to return in generators */
  not exceptionClass = theStopIterationType()
}

// Main detection logic
from FunctionObject specialMethod, ClassObject exceptionClass, string suggestion
where
  // Target non-abstract special methods
  specialMethod.getFunction().isSpecialMethod() and
  not isAbstractFunction(specialMethod) and
  alwaysRaisesException(specialMethod, exceptionClass) and
  (
    // Unnecessary exception cases
    isUnnecessaryRaise(specialMethod.getName(), suggestion) and 
    not exceptionClass.getName() = "NotImplementedError"
    or
    // Incorrect exception type cases
    not isCorrectExceptionType(specialMethod.getName(), exceptionClass) and
    not exceptionClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredException | 
      isPreferredExceptionType(specialMethod.getName(), preferredException) |
      suggestion = "raise " + preferredException.getName() + " instead"
    )
  )
select specialMethod, "Function always raises $@; " + suggestion, exceptionClass, exceptionClass.toString()