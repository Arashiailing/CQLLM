/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when attributes defined in a superclass's __init__ method 
 *              obscure methods defined in subclasses, potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies methods declared in subclasses that become inaccessible
 * due to attributes with identical names being set in the superclass's __init__ method.
 */

import python

// Predicate detecting subclass methods hidden by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject obscuredMethod
) {
  // Verify inheritance relationship between classes
  subCls.getASuperType() = superCls and
  // Ensure subclass declares the method being shadowed
  subCls.declaredAttribute(_) = obscuredMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment within __init__ that causes shadowing
    exists(Attribute assignedAttr |
      assignedAttr = attrAssign.getATarget() and
      // Confirm attribute is assigned to 'self' reference
      assignedAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with obscured method name
      assignedAttr.getName() = obscuredMethod.getName() and
      // Verify assignment occurs within __init__ method scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superCls.hasAttribute(obscuredMethod.getName())
}

// Query to identify obscured methods and their corresponding attribute assignments
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject obscuredMethod
where method_obscured_by_super_attr(subCls, superCls, attrAssign, obscuredMethod)
// Output: obscured method location, descriptive message, attribute assignment location
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + superCls.getName() +
    "'.", attrAssign, "attribute"