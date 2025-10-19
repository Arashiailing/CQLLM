/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies when an attribute defined in a superclass shadows a method with the same name in a subclass
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Detects subclass methods shadowed by superclass attributes:
 * 1. Subclass declares a method
 * 2. Superclass defines an attribute with same name in __init__
 * 3. Superclass lacks a method with this name
 */

import python

// Determines if a subclass method is shadowed by superclass attribute
predicate isMethodShadowedBySuperAttr(
  ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
) {
  // Inheritance relationship exists
  subClass.getASuperType() = superClass and
  // Subclass contains the method
  subClass.declaredAttribute(_) = shadowedMethod and
  // Superclass defines attribute in __init__
  exists(FunctionObject initMethod, Attribute attr |
    // Superclass has __init__ method
    superClass.declaredAttribute("__init__") = initMethod and
    // Assignment targets a self attribute
    attr = attrAssign.getATarget() and
    // Verify assignment to self instance
    attr.getObject().(Name).getId() = "self" and
    // Attribute name matches method name
    attr.getName() = shadowedMethod.getName() and
    // Assignment occurs in superclass __init__ scope
    attrAssign.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Superclass doesn't define method with same name
  not superClass.hasAttribute(shadowedMethod.getName())
}

// Identify shadowed methods and related components
from ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
// Apply shadowing detection logic
where isMethodShadowedBySuperAttr(subClass, superClass, attrAssign, shadowedMethod)
// Output results with method location, message, attribute location, and type label
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by $@ in superclass '" + superClass.getName() + 
    "'.", attrAssign, "attribute definition"