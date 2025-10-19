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

// Helper predicate: Identifies special methods handling attribute access
private predicate handlesAttributeAccess(string methodNameStr) {
  methodNameStr = "__getattribute__" or 
  methodNameStr = "__getattr__" or 
  methodNameStr = "__setattr__"
}

// Helper predicate: Identifies special methods handling container indexing
private predicate handlesContainerIndexing(string methodNameStr) {
  methodNameStr = "__getitem__" or 
  methodNameStr = "__setitem__" or 
  methodNameStr = "__delitem__"
}

// Helper predicate: Identifies special methods implementing arithmetic operations
private predicate implementsArithmeticOps(string methodNameStr) {
  methodNameStr in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Helper predicate: Identifies special methods implementing ordering comparisons
private predicate implementsOrderingOps(string methodNameStr) {
  (methodNameStr = "__lt__" or 
   methodNameStr = "__le__" or 
   methodNameStr = "__gt__" or 
   methodNameStr = "__ge__") 
  or 
  (methodNameStr = "__cmp__" and major_version() = 2)
}

// Helper predicate: Identifies special methods implementing type conversions
private predicate implementsTypeConversion(string methodNameStr) {
  (methodNameStr = "__nonzero__" and major_version() = 2)
  or
  methodNameStr = "__int__" or 
  methodNameStr = "__float__" or 
  methodNameStr = "__long__" or 
  methodNameStr = "__trunc__" or 
  methodNameStr = "__complex__"
}

// Validates if the raised exception type is appropriate for the special method
predicate isValidExceptionType(string methodNameStr, ClassObject exceptionType) {
  // Check for TypeError compatibility with specific method categories
  exceptionType.getAnImproperSuperType() = theTypeErrorType() and
  (
    methodNameStr = "__copy__" or 
    methodNameStr = "__deepcopy__" or 
    methodNameStr = "__call__" or 
    handlesContainerIndexing(methodNameStr) or 
    handlesAttributeAccess(methodNameStr)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(methodNameStr, exceptionType)
  or
  // Check against parent exception types
  isPreferredExceptionType(methodNameStr, exceptionType.getASuperType())
}

// Determines preferred exception types for special method categories
predicate isPreferredExceptionType(string methodNameStr, ClassObject preferredExceptionType) {
  // Attribute methods should raise AttributeError
  handlesAttributeAccess(methodNameStr) and preferredExceptionType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  handlesContainerIndexing(methodNameStr) and preferredExceptionType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  implementsOrderingOps(methodNameStr) and preferredExceptionType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  implementsArithmeticOps(methodNameStr) and preferredExceptionType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  methodNameStr = "__bool__" and preferredExceptionType = theTypeErrorType()
}

// Identifies special methods where exception raising is unnecessary
predicate shouldAvoidException(string methodNameStr, string suggestion) {
  // Hash method should use __hash__ = None instead
  methodNameStr = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  implementsTypeConversion(methodNameStr) and suggestion = "there is no need to implement the method at all."
}

// Detects abstract functions using decorators
predicate isAbstractMethod(FunctionObject specialMethodObj) {
  // Check for decorators containing "abstract"
  specialMethodObj.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that exclusively raise a specific exception
predicate exclusivelyRaisesException(FunctionObject specialMethodObj, ClassObject exceptionType) {
  // Function raises exactly one exception type with no normal exits
  exceptionType = specialMethodObj.getARaisedType() and
  strictcount(specialMethodObj.getARaisedType()) = 1 and
  not exists(specialMethodObj.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionType = theStopIterationType()
}

// Main query: Identifies special methods with non-standard exception handling
from FunctionObject specialMethodObj, ClassObject exceptionType, string suggestion
where
  // Focus on non-abstract special methods
  specialMethodObj.getFunction().isSpecialMethod() and
  not isAbstractMethod(specialMethodObj) and
  exclusivelyRaisesException(specialMethodObj, exceptionType) and
  (
    // Check for unnecessary exception cases
    shouldAvoidException(specialMethodObj.getName(), suggestion) and 
    not exceptionType.getName() = "NotImplementedError"
    or
    // Check for incorrect exception types
    not isValidExceptionType(specialMethodObj.getName(), exceptionType) and
    not exceptionType.getName() = "NotImplementedError" and
    exists(ClassObject preferredExceptionType | 
      isPreferredExceptionType(specialMethodObj.getName(), preferredExceptionType) |
      suggestion = "raise " + preferredExceptionType.getName() + " instead"
    )
  )
select specialMethodObj, "Function always raises $@; " + suggestion, exceptionType, exceptionType.toString()