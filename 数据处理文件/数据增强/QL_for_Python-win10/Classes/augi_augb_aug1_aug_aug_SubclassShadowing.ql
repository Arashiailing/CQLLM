/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when attributes defined in a superclass's __init__ method 
 *              obscure methods defined in subclasses, potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies methods declared in subclasses that become inaccessible
 * due to attributes with identical names being set in the superclass's __init__ method.
 */

import python

// Predicate identifying subclass methods hidden by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  subclass.getASuperType() = superclass and
  // Verify subclass declares the method being shadowed
  subclass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject superInit |
    superclass.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment within __init__ causing shadowing
    exists(Attribute assignedAttr |
      assignedAttr = attributeAssignment.getATarget() and
      // Confirm attribute is assigned to 'self' reference
      assignedAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with shadowed method name
      assignedAttr.getName() = shadowedMethod.getName() and
      // Verify assignment occurs within __init__ method scope
      attributeAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superclass.hasAttribute(shadowedMethod.getName())
}

// Query to identify shadowed methods and corresponding attribute assignments
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
where method_obscured_by_super_attr(subclass, superclass, attributeAssignment, shadowedMethod)
// Output: shadowed method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"