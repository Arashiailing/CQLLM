/**
 * @name Superclass attribute shadows subclass method
 * @description An attribute defined in a superclass method shadows a method in a subclass
 *              when they share the same name, causing the subclass method to be inaccessible.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies subclass methods that are shadowed by attributes defined in their superclass
 */

import python

// Predicate to detect when a subclass method is shadowed by a superclass attribute
predicate shadowed_by_super_class(
  ClassObject subclass, ClassObject superClass, Assign attrAssignment, FunctionObject method
) {
  // Verify inheritance relationship between subclass and superclass
  subclass.getASuperType() = superClass and
  // Ensure the subclass declares the method as an attribute
  subclass.declaredAttribute(_) = method and
  // Verify superclass doesn't define the same method (original definition is intentional)
  not superClass.hasAttribute(method.getName()) and
  // Find matching attribute assignment in superclass __init__ method
  exists(FunctionObject superInit, Attribute selfAttr |
    // Superclass must have an __init__ method
    superClass.declaredAttribute("__init__") = superInit and
    // Attribute must be assigned to 'self' object
    selfAttr = attrAssignment.getATarget() and
    selfAttr.getObject().(Name).getId() = "self" and
    // Attribute name matches the method name
    selfAttr.getName() = method.getName() and
    // Assignment occurs within superclass __init__ scope
    attrAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  )
}

// Query to identify shadowed methods and their locations
from ClassObject subclass, ClassObject superClass, Assign attrAssignment, FunctionObject method
where shadowed_by_super_class(subclass, superClass, attrAssignment, method)
select method.getOrigin(),
  "Method " + method.getName() + " is shadowed by an $@ in superclass '" + superClass.getName() +
    "'.", attrAssignment, "attribute"