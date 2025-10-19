/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when a superclass attribute shadows a subclass method, causing unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies cases where subclass methods are hidden by superclass attributes
 * This can lead to method calls being overridden by attribute assignments
 */

import python

// Check if subclass method is shadowed by superclass attribute
predicate isMethodShadowedBySuperAttribute(
  ClassObject subClass, ClassObject superClass, Assign superAttrAssign, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship
  subClass.getASuperType() = superClass and
  // Verify subclass contains the method
  subClass.declaredAttribute(_) = shadowedMethod and
  // Find matching attribute assignment in superclass constructor
  exists(FunctionObject superInit, Attribute assignedAttr |
    // Superclass has __init__ method
    superClass.declaredAttribute("__init__") = superInit and
    // Attribute assignment target matches
    assignedAttr = superAttrAssign.getATarget() and
    // Assignment is to 'self' attribute
    assignedAttr.getObject().(Name).getId() = "self" and
    // Attribute name matches method name
    assignedAttr.getName() = shadowedMethod.getName() and
    // Assignment occurs in superclass constructor
    superAttrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where superclass intentionally defines same method
  not superClass.hasAttribute(shadowedMethod.getName())
}

from ClassObject subClass, ClassObject superClass, Assign superAttrAssign, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subClass, superClass, superAttrAssign, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", superAttrAssign, "attribute"