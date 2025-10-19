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

// Helper predicates for categorizing special methods
private predicate isAttributeMethod(string mName) {
  mName = "__getattribute__" or 
  mName = "__getattr__" or 
  mName = "__setattr__"
}

private predicate isIndexingMethod(string mName) {
  mName = "__getitem__" or 
  mName = "__setitem__" or 
  mName = "__delitem__"
}

private predicate isArithmeticMethod(string mName) {
  mName in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

private predicate isOrderingMethod(string mName) {
  (mName = "__lt__" or 
   mName = "__le__" or 
   mName = "__gt__" or 
   mName = "__ge__") 
  or 
  (mName = "__cmp__" and major_version() = 2)
}

private predicate isCastMethod(string mName) {
  (mName = "__nonzero__" and major_version() = 2)
  or
  mName = "__int__" or 
  mName = "__float__" or 
  mName = "__long__" or 
  mName = "__trunc__" or 
  mName = "__complex__"
}

// Determines if an exception type is appropriate for a special method
predicate isCorrectExceptionType(string mName, ClassObject excType) {
  // Check for TypeError compatibility with specific method categories
  excType.getAnImproperSuperType() = theTypeErrorType() and
  (
    mName = "__copy__" or 
    mName = "__deepcopy__" or 
    mName = "__call__" or 
    isIndexingMethod(mName) or 
    isAttributeMethod(mName)
  )
  or
  // Check against preferred exception types
  isPreferredExceptionType(mName, excType)
  or
  // Check against parent exception types
  isPreferredExceptionType(mName, excType.getASuperType())
}

// Identifies preferred exception types for special methods
predicate isPreferredExceptionType(string mName, ClassObject excType) {
  // Attribute methods should raise AttributeError
  isAttributeMethod(mName) and excType = theAttributeErrorType()
  or
  // Indexing methods should raise LookupError
  isIndexingMethod(mName) and excType = Object::builtin("LookupError")
  or
  // Ordering methods should raise TypeError
  isOrderingMethod(mName) and excType = theTypeErrorType()
  or
  // Arithmetic methods should raise ArithmeticError
  isArithmeticMethod(mName) and excType = Object::builtin("ArithmeticError")
  or
  // __bool__ method should raise TypeError
  mName = "__bool__" and excType = theTypeErrorType()
}

// Identifies cases where exception raising is unnecessary
predicate isUnnecessaryRaise(string mName, string suggestion) {
  // Hash method should use __hash__ = None instead
  mName = "__hash__" and suggestion = "use __hash__ = None instead"
  or
  // Cast methods don't need implementation
  isCastMethod(mName) and suggestion = "there is no need to implement the method at all."
}

// Identifies abstract functions
predicate isAbstractFunction(FunctionObject func) {
  // Check for decorators containing "abstract"
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// Identifies functions that always raise a specific exception
predicate alwaysRaisesException(FunctionObject func, ClassObject excType) {
  // Function raises exactly one exception type with no normal exits
  excType = func.getARaisedType() and
  strictcount(func.getARaisedType()) = 1 and
  not exists(func.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not excType = theStopIterationType()
}

// Main query to identify special methods with non-standard exception handling
from FunctionObject func, ClassObject excClass, string suggestion
where
  // Filter for special methods that aren't abstract
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