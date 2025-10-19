/**
 * @name Non-standard exception raised in special method
 * @description Detects special methods that raise non-standard exceptions, violating interface conventions.
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

// Classifies attribute access special methods
private predicate attributeAccessMethod(string specialMethodName) {
  specialMethodName = "__getattribute__" or 
  specialMethodName = "__getattr__" or 
  specialMethodName = "__setattr__"
}

// Classifies container indexing special methods
private predicate containerIndexingMethod(string specialMethodName) {
  specialMethodName = "__getitem__" or 
  specialMethodName = "__setitem__" or 
  specialMethodName = "__delitem__"
}

// Classifies arithmetic operation special methods
private predicate arithmeticOperationMethod(string specialMethodName) {
  specialMethodName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// Classifies comparison operation special methods
private predicate comparisonOperationMethod(string specialMethodName) {
  (specialMethodName = "__lt__" or 
   specialMethodName = "__le__" or 
   specialMethodName = "__gt__" or 
   specialMethodName = "__ge__") 
  or 
  (specialMethodName = "__cmp__" and major_version() = 2)
}

// Classifies type conversion special methods
private predicate typeConversionMethod(string specialMethodName) {
  (specialMethodName = "__nonzero__" and major_version() = 2)
  or
  specialMethodName = "__int__" or 
  specialMethodName = "__float__" or 
  specialMethodName = "__long__" or 
  specialMethodName = "__trunc__" or 
  specialMethodName = "__complex__"
}

// Validates appropriate exception types for special methods
predicate validExceptionForMethod(string specialMethodName, ClassObject exceptionClass) {
  // Check direct preferred exception types
  preferredExceptionForMethod(specialMethodName, exceptionClass)
  or
  // Check inheritance from preferred exception types
  preferredExceptionForMethod(specialMethodName, exceptionClass.getASuperType())
  or
  // Special handling for TypeError-compatible cases
  exceptionClass.getAnImproperSuperType() = theTypeErrorType() and
  (
    specialMethodName = "__copy__" or 
    specialMethodName = "__deepcopy__" or 
    specialMethodName = "__call__" or 
    containerIndexingMethod(specialMethodName) or 
    attributeAccessMethod(specialMethodName)
  )
}

// Identifies preferred exception types for specific special methods
predicate preferredExceptionForMethod(string specialMethodName, ClassObject exceptionClass) {
  // Attribute methods should raise AttributeError
  attributeAccessMethod(specialMethodName) and exceptionClass = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  containerIndexingMethod(specialMethodName) and exceptionClass = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  comparisonOperationMethod(specialMethodName) and exceptionClass = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  arithmeticOperationMethod(specialMethodName) and exceptionClass = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  specialMethodName = "__bool__" and exceptionClass = theTypeErrorType()
}

// Identifies cases where raising exceptions is unnecessary
predicate unnecessaryExceptionRaise(string specialMethodName, string suggestion) {
  // Hash method should use __hash__ = None instead
  specialMethodName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  typeConversionMethod(specialMethodName) and suggestion = "there is no need to implement the method at all."
}

// Identifies abstract methods through decorators
predicate abstractMethod(FunctionObject specialMethod) {
  // Check for decorators containing "abstract"
  specialMethod.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that consistently raise a specific exception
predicate consistentExceptionRaise(FunctionObject specialMethod, ClassObject exceptionClass) {
  // Function raises exactly one exception type with no normal exits
  exceptionClass = specialMethod.getARaisedType() and
  strictcount(specialMethod.getARaisedType()) = 1 and
  not exists(specialMethod.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not exceptionClass = theStopIterationType()
}

// Main query: detects special methods with non-standard exception handling
from FunctionObject specialMethodObj, ClassObject raisedExceptionClass, string suggestionMsg
where
  // Target special methods that aren't abstract
  specialMethodObj.getFunction().isSpecialMethod() and
  not abstractMethod(specialMethodObj) and
  consistentExceptionRaise(specialMethodObj, raisedExceptionClass) and
  // Exclude NotImplementedError as it's a special case
  not raisedExceptionClass.getName() = "NotImplementedError" and
  (
    // Check for unnecessary exception cases
    unnecessaryExceptionRaise(specialMethodObj.getName(), suggestionMsg)
    or
    // Check for incorrect exception types
    (
      not validExceptionForMethod(specialMethodObj.getName(), raisedExceptionClass) and
      exists(ClassObject preferredException | 
        preferredExceptionForMethod(specialMethodObj.getName(), preferredException) |
        suggestionMsg = "raise " + preferredException.getName() + " instead"
      )
    )
  )
select specialMethodObj, "Function always raises $@; " + suggestionMsg, raisedExceptionClass, raisedExceptionClass.toString()