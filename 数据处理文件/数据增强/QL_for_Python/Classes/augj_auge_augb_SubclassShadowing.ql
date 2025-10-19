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
 * This query detects methods in subclasses that are overshadowed by attributes in superclasses:
 * 1. A method is defined in a subclass
 * 2. An attribute with the same name is defined in the superclass's __init__ method
 * 3. The superclass does not define a method with the same name
 */

import python

// Detects when a subclass method is shadowed by a superclass attribute
predicate methodShadowedBySuperAttr(
  ClassObject childClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
) {
  // Verify inheritance relationship
  childClass.getASuperType() = superClass and
  // Confirm method exists in subclass
  childClass.declaredAttribute(_) = shadowedMethod and
  // Check superclass __init__ contains matching attribute assignment
  exists(FunctionObject initMethod, Attribute targetAttr |
    // Superclass must define __init__
    superClass.declaredAttribute("__init__") = initMethod and
    // Assignment target must be a self attribute
    targetAttr = attrAssign.getATarget() and
    // Verify assignment is to self instance
    targetAttr.getObject().(Name).getId() = "self" and
    // Attribute name matches method name
    targetAttr.getName() = shadowedMethod.getName() and
    // Assignment occurs within superclass __init__ scope
    attrAssign.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Ensure superclass doesn't define a method with same name
  not superClass.hasAttribute(shadowedMethod.getName())
}

// Query to identify shadowed methods and related components
from ClassObject childClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
// Apply shadowing detection predicate
where methodShadowedBySuperAttr(childClass, superClass, attrAssign, shadowedMethod)
// Output results: method location, descriptive message, attribute assignment location, and type label
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by $@ in superclass '" + superClass.getName() + 
    "'.", attrAssign, "attribute definition"