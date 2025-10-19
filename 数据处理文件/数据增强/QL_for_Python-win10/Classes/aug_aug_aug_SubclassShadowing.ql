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
 * Identifies methods in subclasses that are shadowed by attributes 
 * defined in the superclass's __init__ method.
 */

import python

// Predicate to detect shadowing of subclass methods by superclass attributes
predicate shadowed_by_super_class(
  ClassObject subClass, ClassObject superClass, Assign shadowingAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Verify subclass contains the method being shadowed
  subClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject superClassInitMethod |
    superClass.declaredAttribute("__init__") = superClassInitMethod and
    // Ensure assignment occurs within __init__ method scope
    shadowingAssignment.getScope() = superClassInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify attribute assignment that shadows the method
  exists(Attribute shadowingAttribute |
    shadowingAttribute = shadowingAssignment.getATarget() and
    // Confirm attribute is assigned to 'self'
    shadowingAttribute.getObject().(Name).getId() = "self" and
    // Match attribute name with shadowed method name
    shadowingAttribute.getName() = shadowedMethod.getName()
  ) and
  // Exclude cases where superclass defines the same method
  not superClass.hasAttribute(shadowedMethod.getName())
}

// Query to find shadowed methods and their locations
from ClassObject subClass, ClassObject superClass, Assign shadowingAssignment, FunctionObject shadowedMethod
where shadowed_by_super_class(subClass, superClass, shadowingAssignment, shadowedMethod)
// Output: shadowed method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in superclass '" + superClass.getName() +
    "'.", shadowingAssignment, "attribute"