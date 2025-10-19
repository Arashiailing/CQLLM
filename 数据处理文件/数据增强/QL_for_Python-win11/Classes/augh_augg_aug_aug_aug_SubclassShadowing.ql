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
 * This analysis identifies methods in subclasses that become inaccessible due to 
 * attribute assignments with matching names in the superclass's __init__ method.
 * Such shadowing can lead to runtime errors when attempting to call the shadowed method.
 */

import python

// Predicate identifying subclass methods hidden by superclass attributes
predicate method_shadowed_by_super_attribute(
  ClassObject subClass, ClassObject superClass, Assign shadowingAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Confirm subclass contains the method being shadowed
  subClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method where shadowing occurs
  exists(FunctionObject superInit |
    superClass.declaredAttribute("__init__") = superInit and
    // Verify assignment occurs within __init__ method scope
    shadowingAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify attribute assignment causing the shadowing
  exists(Attribute assignedAttr |
    assignedAttr = shadowingAssignment.getATarget() and
    // Ensure attribute is assigned to 'self' (instance attribute)
    assignedAttr.getObject().(Name).getId() = "self" and
    // Match attribute name with shadowed method name
    assignedAttr.getName() = shadowedMethod.getName()
  ) and
  // Exclude cases where superclass defines same method (normal override)
  not superClass.hasAttribute(shadowedMethod.getName())
}

// Query to find shadowed methods and their shadowing attributes
from ClassObject subClass, ClassObject superClass, Assign shadowingAssignment, FunctionObject shadowedMethod
where method_shadowed_by_super_attribute(subClass, superClass, shadowingAssignment, shadowedMethod)
// Output: shadowed method location, detailed message, shadowing attribute location
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is obscured by an $@ in superclass '" + superClass.getName() +
    "', making it inaccessible through normal attribute access.", shadowingAssignment, "attribute assignment"