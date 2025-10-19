/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods raising non-standard exceptions that violate expected interfaces.
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

// Helper predicates for special method classification
private predicate isAttributeMethod(string methodName) {
  methodName in ["__getattribute__", "__getattr__", "__setattr__"]
}

private predicate isIndexingMethod(string methodName) {
  methodName in ["__getitem__", "__setitem__", "__delitem__"]
}

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

private predicate isOrderingMethod(string methodName) {
  methodName in ["__lt__", "__le__", "__gt__", "__ge__"] 
  or 
  (methodName = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName in ["__int__", "__float__", "__long__", "__trunc__", "__complex__"]
}

// Exception type validation logic
predicate isCorrectExceptionType(string methodName, ClassObject excClass) {
  // Validate TypeError compatibility for specific method categories
  excClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName in ["__copy__", "__deepcopy__", "__call__"] 
    or 
    isIndexingMethod(methodName) 
    or 
    isAttributeMethod(methodName)
  )
  or
  // Validate preferred exception types
  isPreferredExceptionType(methodName, excClass)
  or
  // Validate parent exception types
  isPreferredExceptionType(methodName, excClass.getASuperType())
}

// Preferred exception type definitions
predicate isPreferredExceptionType(string methodName, ClassObject excClass) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(methodName) and excClass = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(methodName) and excClass = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(methodName) and excClass = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(methodName) and excClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodName = "__bool__" and excClass = theTypeErrorType()
}

// Unnecessary exception handling detection
predicate isUnnecessaryRaise(string methodName, string suggestion) {
  // Hash method should use __hash__ = None instead
  methodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and suggestion = "there is no need to implement the method at all."
}

// Function behavior analysis predicates
predicate isAbstractFunction(FunctionObject func) {
  // Check for decorators containing "abstract"
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

predicate alwaysRaisesException(FunctionObject func, ClassObject excClass) {
  // Function raises exactly one exception type with no normal exits
  excClass = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  not exists(func.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not excClass = theStopIterationType()
}

// Main query logic
from FunctionObject func, ClassObject excClass, string suggestion
where
  // Identify non-abstract special methods
  func.getFunction().isSpecialMethod() and
  not isAbstractFunction(func) and
  alwaysRaisesException(func, excClass) and
  (
    // Check for unnecessary exception cases
    isUnnecessaryRaise(func.getName(), suggestion) and 
    not excClass.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isCorrectExceptionType(func.getName(), excClass) and
    not excClass.getName() = "NotImplementedError" and
    exists(ClassObject preferredExc | 
      isPreferredExceptionType(func.getName(), preferredExc) |
      suggestion = "raise " + preferredExc.getName() + " instead"
    )
  )
select func, "Function always raises $@; " + suggestion, excClass, excClass.toString()