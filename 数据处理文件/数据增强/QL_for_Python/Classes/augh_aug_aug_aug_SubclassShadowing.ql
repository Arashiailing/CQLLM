/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass's __init__ method 
 *              shadows a method defined in a subclass, potentially causing unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies scenarios where a method defined in a subclass is shadowed
 * by an attribute assignment in the superclass's __init__ method. Such shadowing can
 * lead to unexpected behavior when attempting to call the method on subclass instances.
 */

import python

// Predicate to detect shadowing of subclass methods by superclass attributes
predicate shadowed_by_super_class(
  ClassObject derivedClass, ClassObject baseClass, Assign shadowingAttrAssignment, FunctionObject shadowedSubMethod
) {
  // Establish inheritance relationship between classes
  derivedClass.getASuperType() = baseClass and
  // Verify subclass contains the method being shadowed
  derivedClass.declaredAttribute(_) = shadowedSubMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject baseClassInitMethod |
    baseClass.declaredAttribute("__init__") = baseClassInitMethod and
    // Ensure assignment occurs within __init__ method scope
    shadowingAttrAssignment.getScope() = baseClassInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify attribute assignment that shadows the method
  exists(Attribute shadowingAttr |
    shadowingAttr = shadowingAttrAssignment.getATarget() and
    // Confirm attribute is assigned to 'self'
    shadowingAttr.getObject().(Name).getId() = "self" and
    // Match attribute name with shadowed method name
    shadowingAttr.getName() = shadowedSubMethod.getName()
  ) and
  // Exclude cases where superclass defines the same method
  not baseClass.hasAttribute(shadowedSubMethod.getName())
}

// Query to find shadowed methods and their locations
from ClassObject derivedClass, ClassObject baseClass, Assign shadowingAttrAssignment, FunctionObject shadowedSubMethod
where shadowed_by_super_class(derivedClass, baseClass, shadowingAttrAssignment, shadowedSubMethod)
// Output: shadowed method location, descriptive message, attribute assignment location
select shadowedSubMethod.getOrigin(),
  "Method " + shadowedSubMethod.getName() + " is shadowed by an $@ in superclass '" + baseClass.getName() +
    "'.", shadowingAttrAssignment, "attribute"