/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass shadows a method in a subclass.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies cases where a subclass method is shadowed by an attribute
 * defined in the superclass's __init__ method.
 */

import python

// Predicate to detect method shadowing by superclass attributes
predicate isMethodShadowedBySuperAttribute(
  ClassObject subclass, ClassObject superclass, Assign attrAssign, FunctionObject shadowedFunc
) {
  // Verify inheritance relationship
  subclass.getASuperType() = superclass and
  // Confirm subclass contains the shadowed method
  subclass.declaredAttribute(_) = shadowedFunc and
  // Check for matching attribute assignment in superclass __init__
  exists(FunctionObject superInit, Attribute assignedAttr |
    // Locate superclass __init__ method
    superclass.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment target
    assignedAttr = attrAssign.getATarget() and
    // Verify assignment is to self attribute
    assignedAttr.getObject().(Name).getId() = "self" and
    // Ensure attribute name matches method name
    assignedAttr.getName() = shadowedFunc.getName() and
    // Confirm assignment occurs in superclass __init__
    attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where superclass intentionally defines same-named method
  not superclass.hasAttribute(shadowedFunc.getName())
}

// Query for shadowed methods with relevant context
from ClassObject subclass, ClassObject superclass, Assign attrAssign, FunctionObject shadowedFunc
where isMethodShadowedBySuperAttribute(subclass, superclass, attrAssign, shadowedFunc)
// Output shadowed method location with diagnostic message
select shadowedFunc.getOrigin(),
  "Method " + shadowedFunc.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attrAssign, "attribute"