/**
 * @name Useless class
 * @description Identifies classes that define only one public method (excluding `__init__` or `__new__`) 
 *              and should be refactored into functions for better maintainability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/useless-class
 */

import python

// Determines if a class qualifies as useless based on multiple criteria
predicate is_useless_class(Class targetClass, int publicMethodCount) {
  // Calculate public methods excluding initializers
  publicMethodCount = count(Function method |
    method = targetClass.getAMethod() and
    not method = targetClass.getInitMethod()
  ) and
  (publicMethodCount = 0 or publicMethodCount = 1) and
  
  // Verify absence of special methods
  not exists(Function specialMthd |
    specialMthd = targetClass.getAMethod() and
    specialMthd.isSpecialMethod()
  ) and
  
  // Confirm no inheritance hierarchy beyond object
  not exists(ClassValue current, ClassValue parent |
    current.getScope() = targetClass and
    parent != ClassValue::object()
  |
    parent.getABaseType() = current or
    current.getABaseType() = parent
  ) and
  // Ensure only object as base class
  not exists(Expr baseExpr |
    baseExpr = targetClass.getABase() and
    (not baseExpr instanceof Name or baseExpr.(Name).getId() != "object")
  ) and
  
  // Check for absence of decorators
  not exists(targetClass.getADecorator()) and
  
  // Validate class doesn't maintain state
  not (
    // Detect attribute storage operations
    exists(Function stateMethod, ExprContext context |
      stateMethod.getScope() = targetClass and
      (context instanceof Store or context instanceof AugStore)
    |
      exists(Subscript subscriptExpr |
        subscriptExpr.getScope() = stateMethod and
        subscriptExpr.getCtx() = context
      )
      or
      exists(Attribute attributeExpr |
        attributeExpr.getScope() = stateMethod and
        attributeExpr.getCtx() = context
      )
    )
    // Detect state-modifying method calls
    or
    exists(Function stateMethod, Call callExpr, Attribute attributeExpr, string stateMethodName |
      stateMethod.getScope() = targetClass and
      callExpr.getScope() = stateMethod and
      callExpr.getFunc() = attributeExpr and
      attributeExpr.getName() = stateMethodName
    |
      stateMethodName in ["pop", "remove", "discard", "extend", "append"]
    )
  ) and
  
  // Basic class property validations
  targetClass.isTopLevel() and
  targetClass.isPublic() and
  not targetClass.isProbableMixin()
}

// Query to identify useless classes and generate diagnostic messages
from Class targetClass, int publicMethodCount, string message
where
  is_useless_class(targetClass, publicMethodCount) and
  (
    publicMethodCount = 1 and
    message =
      "Class " + targetClass.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    publicMethodCount = 0 and
    message =
      "Class " + targetClass.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select targetClass, message