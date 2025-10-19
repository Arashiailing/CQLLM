/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies when attributes set in a superclass's __init__ method 
 *              hide methods defined in subclasses, potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis detects methods declared in subclasses that become inaccessible
 * due to attributes with matching names being assigned in the superclass's __init__ method.
 */

import python

// Predicate identifying subclass methods hidden by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  childClass.getASuperType() = parentClass and
  // Verify subclass declares the method being shadowed
  childClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject parentInit |
    parentClass.declaredAttribute("__init__") = parentInit and
    // Identify attribute assignment within __init__ causing shadowing
    exists(Attribute assignedAttribute |
      assignedAttribute = attributeAssignment.getATarget() and
      // Confirm attribute is assigned to 'self' reference
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Match attribute name with shadowed method name
      assignedAttribute.getName() = shadowedMethod.getName() and
      // Verify assignment occurs within __init__ method scope
      attributeAssignment.getScope() = parentInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// Query to identify shadowed methods and corresponding attribute assignments
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
where method_obscured_by_super_attr(childClass, parentClass, attributeAssignment, shadowedMethod)
// Output: shadowed method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"