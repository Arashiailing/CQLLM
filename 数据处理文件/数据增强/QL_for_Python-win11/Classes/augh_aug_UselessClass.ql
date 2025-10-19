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

// Check if class has insufficient public methods (excluding __init__)
predicate has_insufficient_public_methods(Class cls, int methodCount) {
  (methodCount = 0 or methodCount = 1) and
  methodCount = count(Function m |
    m = cls.getAMethod() and
    not m = cls.getInitMethod()
  )
}

// Check if class lacks any special methods
predicate lacks_special_methods(Class cls) {
  not exists(Function m |
    m = cls.getAMethod() and
    m.isSpecialMethod()
  )
}

// Check if class has no inheritance (only inherits from object)
predicate has_no_inheritance(Class cls) {
  // Verify no parent classes exist (except object)
  not exists(ClassValue current, ClassValue parent |
    current.getScope() = cls and
    parent != ClassValue::object()
  |
    parent.getABaseType() = current or
    current.getABaseType() = parent
  ) and
  // Verify base class is only object
  not exists(Expr base |
    base = cls.getABase() and
    (not base instanceof Name or base.(Name).getId() != "object")
  )
}

// Check if class has decorators
predicate is_decorated(Class cls) {
  exists(cls.getADecorator())
}

// Check if class maintains state through attribute operations
predicate maintains_state(Class cls) {
  // Check for attribute storage operations
  exists(Function m, ExprContext ctx |
    m.getScope() = cls and
    (ctx instanceof Store or ctx instanceof AugStore)
  |
    exists(Subscript sub |
      sub.getScope() = m and
      sub.getCtx() = ctx
    )
    or
    exists(Attribute a |
      a.getScope() = m and
      a.getCtx() = ctx
    )
  )
  // Check for state-modifying method calls
  or
  exists(Function m, Call call, Attribute a2, string methodName |
    m.getScope() = cls and
    call.getScope() = m and
    call.getFunc() = a2 and
    a2.getName() = methodName
  |
    methodName in ["pop", "remove", "discard", "extend", "append"]
  )
}

// Comprehensive check for useless classes
predicate is_useless_class(Class cls, int methodCount) {
  cls.isTopLevel() and
  cls.isPublic() and
  has_no_inheritance(cls) and
  has_insufficient_public_methods(cls, methodCount) and
  lacks_special_methods(cls) and
  not cls.isProbableMixin() and
  not is_decorated(cls) and
  not maintains_state(cls)
}

// Query useless classes and generate diagnostic messages
from Class cls, int methodCount, string diagnosticMessage
where
  is_useless_class(cls, methodCount) and
  (
    methodCount = 1 and
    diagnosticMessage =
      "Class " + cls.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    methodCount = 0 and
    diagnosticMessage =
      "Class " + cls.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select cls, diagnosticMessage