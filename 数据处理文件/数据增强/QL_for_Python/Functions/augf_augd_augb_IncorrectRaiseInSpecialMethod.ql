/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, violating expected interfaces.
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

// Identifies attribute-related special methods
private predicate isAttributeMethod(string methodName) {
  methodName = "__getattribute__" or 
  methodName = "__getattr__" or 
  methodName = "__setattr__"
}

// Identifies indexing-related special methods
private predicate isIndexingMethod(string methodName) {
  methodName = "__getitem__" or 
  methodName = "__setitem__" or 
  methodName = "__delitem__"
}

// Identifies arithmetic operation special methods
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

// Identifies ordering comparison special methods
private predicate isOrderingMethod(string methodName) {
  (methodName = "__lt__" or 
   methodName = "__le__" or 
   methodName = "__gt__" or 
   methodName = "__ge__")
  or
  (methodName = "__cmp__" and major_version() = 2)
}

// Identifies type conversion special methods
private predicate isCastMethod(string methodName) {
  (methodName = "__nonzero__" and major_version() = 2)
  or
  methodName = "__int__" or 
  methodName = "__float__" or 
  methodName = "__long__" or 
  methodName = "__trunc__" or 
  methodName = "__complex__"
}

// Validates if exception type is appropriate for special method
predicate isValidExceptionType(string methodName, ClassObject excClass) {
  // Handles valid TypeError cases for specific method categories
  excClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodName = "__copy__" or
    methodName = "__deepcopy__" or
    methodName = "__call__" or
    isIndexingMethod(methodName) or
    isAttributeMethod(methodName)
  )
  or
  // Checks against preferred exception types
  isPreferredException(methodName, excClass)
  or
  // Checks parent types against preferred exceptions
  isPreferredException(methodName, excClass.getASuperType())
}

// Identifies preferred exception types for special methods
predicate isPreferredException(string methodName, ClassObject excClass) {
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

// Detects cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string methodName, string fixRec) {
  // __hash__ methods should use __hash__ = None instead
  methodName = "__hash__" and fixRec = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(methodName) and fixRec = "there is no need to implement the method at all."
}

// Identifies abstract functions
predicate isAbstractFunction(FunctionObject func) {
  // Checks for abstract decorator
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that consistently raise a specific exception
predicate consistentlyRaises(FunctionObject func, ClassObject excClass) {
  // Function raises only this exception type
  excClass = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  // No normal exit paths
  not exists(func.getFunction().getANormalExit()) and
  // Excludes StopIteration (equivalent to return in generators)
  not excClass = theStopIterationType()
}

// Main query to detect non-standard exceptions in special methods
from FunctionObject method, ClassObject raisedExc, string fixRec
where
  // Target non-abstract special methods
  method.getFunction().isSpecialMethod() and
  not isAbstractFunction(method) and
  consistentlyRaises(method, raisedExc) and
  (
    // Case 1: Unnecessary exception raising
    isUnnecessaryRaise(method.getName(), fixRec) and 
    not raisedExc.getName() = "NotImplementedError"
    or
    // Case 2: Incorrect exception type with recommended alternative
    not isValidExceptionType(method.getName(), raisedExc) and
    not raisedExc.getName() = "NotImplementedError" and
    exists(ClassObject preferredExc | 
      isPreferredException(method.getName(), preferredExc) |
      fixRec = "raise " + preferredExc.getName() + " instead"
    )
  )
select method, "Function always raises $@; " + fixRec, raisedExc, raisedExc.toString()