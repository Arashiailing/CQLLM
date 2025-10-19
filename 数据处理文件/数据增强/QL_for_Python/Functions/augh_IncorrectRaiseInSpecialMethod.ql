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

// Determines if a method name belongs to attribute-related special methods
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Determines if a method name belongs to indexing-related special methods
private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Determines if a method name belongs to arithmetic operation special methods
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

// Determines if a method name belongs to comparison special methods
private predicate isOrderingMethod(string methodName) {
  methodName = "__lt__" or
  methodName = "__le__" or
  methodName = "__gt__" or
  methodName = "__ge__" or
  (methodName = "__cmp__" and major_version() = 2)
}

// Determines if a method name belongs to type conversion special methods
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2) or
  methodName = "__int__" or
  methodName = "__float__" or
  methodName = "__long__" or
  methodName = "__trunc__" or
  methodName = "__complex__"
}

// Checks if the raised exception type is appropriate for the special method
predicate isCorrectRaise(string methodName, ClassObject exceptionType) {
  // Handle cases where TypeError is acceptable
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
  isPreferredRaise(methodName, exceptionType)
  or
  // Check parent types against preferred exceptions
  isPreferredRaise(methodName, exceptionType.getASuperType())
}

// Determines the preferred exception type for a given special method
predicate isPreferredRaise(string methodName, ClassObject exceptionType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and exceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and exceptionType = Object::builtin("LookupError")
  or
  // Comparison methods should raise TypeError
  isOrderingMethod(methodName) and exceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and exceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ should raise TypeError
  methodName = "__bool__" and exceptionType = theTypeErrorType()
}

// Identifies special methods that don't need to raise exceptions
predicate shouldNotRaise(string methodName, string recommendation) {
  // __hash__ should use __hash__ = None instead
  methodName = "__hash__" and recommendation = "use __hash__ = None instead"
  or
  // Cast methods can be omitted entirely
  isCastMethod(methodName) and recommendation = "there is no need to implement the method at all."
}

// Checks if a function is decorated as abstract
predicate isAbstractFunction(FunctionObject function) {
  function.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Determines if a function always raises a specific exception type
predicate alwaysRaises(FunctionObject function, ClassObject exceptionType) {
  exceptionType = function.getARaisedType() and
  strictcount(function.getARaisedType()) = 1 and
  not exists(function.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query: Identifies special methods that always raise non-standard exceptions
from FunctionObject function, ClassObject exceptionType, string recommendation
where
  function.getFunction().isSpecialMethod() and
  not isAbstractFunction(function) and
  alwaysRaises(function, exceptionType) and
  (
    // Cases where no exception should be raised
    shouldNotRaise(function.getName(), recommendation) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Cases where incorrect exception type is raised
    not isCorrectRaise(function.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredType | isPreferredRaise(function.getName(), preferredType) |
      recommendation = "raise " + preferredType.getName() + " instead"
    )
  )
select function, "Function always raises $@; " + recommendation, exceptionType, exceptionType.toString()