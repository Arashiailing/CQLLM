/**
 * @name Useless class
 * @description Class only defines one public method (apart from `__init__` or `__new__`) and should be replaced by a function
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/useless-class
 */

import python

// Determines if a class has fewer than two public methods (excluding __init__)
predicate has_minimal_public_methods(Class cls, int publicMethodCount) {
  // Check for 0 or 1 public methods, excluding the initializer
  (publicMethodCount = 0 or publicMethodCount = 1) and
  publicMethodCount = count(Function method | 
    method = cls.getAMethod() and 
    not method = cls.getInitMethod()
  )
}

// Verifies that a class doesn't implement any special methods
predicate lacks_special_methods(Class cls) {
  // Ensure no special methods are defined in the class
  not exists(Function method | 
    method = cls.getAMethod() and 
    method.isSpecialMethod()
  )
}

// Confirms a class has no inheritance relationships
predicate is_inheritance_free(Class cls) {
  // Check for absence of parent classes (excluding object)
  not exists(ClassValue classVal, ClassValue otherClass |
    classVal.getScope() = cls and
    otherClass != ClassValue::object()
  |
    otherClass.getABaseType() = classVal or
    classVal.getABaseType() = otherClass
  ) and
  // Verify all base classes are explicitly 'object'
  not exists(Expr baseExpr | baseExpr = cls.getABase() |
    not baseExpr instanceof Name or 
    baseExpr.(Name).getId() != "object"
  )
}

// Checks if a class has decorators applied
predicate has_decorators(Class cls) { 
  exists(cls.getADecorator()) 
}

// Determines if a class maintains state
predicate maintains_state(Class cls) {
  // Detect state storage through attribute/subscript assignments
  exists(Function method, ExprContext context |
    method.getScope() = cls and
    (context instanceof Store or context instanceof AugStore)
  |
    exists(Subscript subscript | 
      subscript.getScope() = method and 
      subscript.getCtx() = context
    )
    or
    exists(Attribute attribute | 
      attribute.getScope() = method and 
      attribute.getCtx() = context
    )
  )
  // Detect state-modifying method calls
  or
  exists(Function method, Call call, Attribute attribute, string methodName |
    method.getScope() = cls and
    call.getScope() = method and
    call.getFunc() = attribute and
    attribute.getName() = methodName
  |
    methodName in ["pop", "remove", "discard", "extend", "append"]
  )
}

// Identifies classes that serve no useful purpose
predicate is_useless_class(Class cls, int publicMethodCount) {
  // Verify class meets all criteria for being useless
  cls.isTopLevel() and
  cls.isPublic() and
  is_inheritance_free(cls) and
  has_minimal_public_methods(cls, publicMethodCount) and
  lacks_special_methods(cls) and
  not cls.isProbableMixin() and
  not has_decorators(cls) and
  not maintains_state(cls)
}

// Generate results for useless classes with contextual messages
from Class cls, int publicMethodCount, string message
where
  is_useless_class(cls, publicMethodCount) and
  (
    // Handle single-method classes
    publicMethodCount = 1 and
    message =
      "Class " + cls.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    // Handle empty classes
    publicMethodCount = 0 and
    message =
      "Class " + cls.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select cls, message