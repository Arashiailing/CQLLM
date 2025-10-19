/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when a subclass method is hidden by an attribute defined in its superclass.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 *
 * Identifies cases where attributes defined in superclass initializers shadow methods
 * declared in subclasses. This occurs when a superclass __init__ method assigns an
 * attribute with the same name as a method in its subclass, effectively hiding the
 * subclass method. Excludes intentional overrides where the superclass also defines
 * a method with the same name.
 */

import python

// Determines if a subclass method is shadowed by an attribute in its superclass
predicate isMethodShadowedBySuperAttribute(
  ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Verify the subclass declares the method being shadowed
  subClass.declaredAttribute(_) = shadowedMethod and
  // Find matching attribute assignment in superclass initializer
  exists(FunctionObject superInit, Attribute assignedAttr |
    // Superclass must define __init__ method
    superClass.declaredAttribute("__init__") = superInit and
    // Attribute assignment targets the assigned attribute
    assignedAttr = attrAssignment.getATarget() and
    // Assignment is to 'self' instance
    assignedAttr.getObject().(Name).getId() = "self" and
    // Attribute name matches the shadowed method name
    assignedAttr.getName() = shadowedMethod.getName() and
    // Assignment occurs within superclass initializer scope
    attrAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where superclass intentionally defines同名 method
  not superClass.hasAttribute(shadowedMethod.getName())
}

from ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subClass, superClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssignment, "attribute"