/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass's __init__ method 
 *              shadows a method with the same name in a subclass.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query identifies methods in subclasses that are shadowed by attributes 
 * defined in the superclass's __init__ method. The detection criteria are:
 * 1. A method is declared in a subclass
 * 2. An attribute with the same name is defined in the superclass's __init__ method
 * 3. The superclass does not define a method with the same name
 */

import python

// Predicate to determine if a subclass method is shadowed by a superclass attribute
predicate isShadowedBySuperclassAttribute(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between subclass and superclass
  subclass.getASuperType() = superclass and
  // Confirm that the subclass declares the target method
  subclass.declaredAttribute(_) = shadowedMethod and
  // Verify attribute definition in superclass's __init__ method
  exists(FunctionObject initializer, Attribute targetAttribute |
    // Superclass contains an __init__ method
    superclass.declaredAttribute("__init__") = initializer and
    // The target of the assignment is a self member
    targetAttribute = attributeAssignment.getATarget() and
    // Ensure the assignment target is a self instance
    targetAttribute.getObject().(Name).getId() = "self" and
    // Attribute name matches the subclass method name
    targetAttribute.getName() = shadowedMethod.getName() and
    // Assignment occurs within the scope of the superclass's __init__ method
    attributeAssignment.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where the superclass already defines a method with the same name
  not superclass.hasAttribute(shadowedMethod.getName())
}

// Query for shadowed methods and their related elements
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
// Apply the shadowing detection predicate
where isShadowedBySuperclassAttribute(subclass, superclass, attributeAssignment, shadowedMethod)
// Output results: method location, descriptive message, attribute assignment location, and type label
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by $@ in superclass '" + superclass.getName() + 
    "'.", attributeAssignment, "attribute definition"