/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies when an attribute defined in a superclass's __init__ method 
 *              obscures a method defined in a subclass, potentially leading to unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Detects methods in subclasses that are obscured by attributes 
 * initialized in the superclass's __init__ method.
 */

import python

// Predicate identifying subclass methods obscured by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject subCls, ClassObject superCls, Assign attrAssignStmt, FunctionObject obscuredMethod
) {
  // Validate inheritance relationship
  subCls.getASuperType() = superCls and
  // Ensure subclass declares the method being obscured
  subCls.declaredAttribute(_) = obscuredMethod and
  // Locate superclass __init__ method containing the obscuring attribute
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment within __init__ that obscures the method
    exists(Attribute assignedAttr |
      assignedAttr = attrAssignStmt.getATarget() and
      // Verify attribute is assigned to 'self'
      assignedAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with obscured method name
      assignedAttr.getName() = obscuredMethod.getName() and
      // Confirm assignment occurs within __init__ method scope
      attrAssignStmt.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superCls.hasAttribute(obscuredMethod.getName())
}

// Query to detect obscured methods and their corresponding attribute assignments
from ClassObject subCls, ClassObject superCls, Assign attrAssignStmt, FunctionObject obscuredMethod
where method_obscured_by_super_attr(subCls, superCls, attrAssignStmt, obscuredMethod)
// Output: obscured method location, descriptive message, attribute assignment location
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + superCls.getName() +
    "'.", attrAssignStmt, "attribute"