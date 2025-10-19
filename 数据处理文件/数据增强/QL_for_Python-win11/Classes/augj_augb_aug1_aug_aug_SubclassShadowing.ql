/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies methods in subclasses that become inaccessible due to 
 *              attributes with identical names defined in the superclass's __init__ method,
 *              potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis detects methods declared in subclasses that are shadowed by attributes
 * set in the superclass's __init__ method, making the subclass methods inaccessible.
 */

import python

// Predicate identifying subclass methods hidden by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship
  childClass.getASuperType() = parentClass and
  // Verify subclass declares the shadowed method
  childClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the shadowing attribute
  exists(FunctionObject parentInitMethod |
    parentClass.declaredAttribute("__init__") = parentInitMethod and
    // Identify attribute assignment within __init__ causing shadowing
    exists(Attribute assignedAttribute |
      assignedAttribute = attributeAssignment.getATarget() and
      // Confirm attribute is assigned to 'self' reference
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Match attribute name with shadowed method name
      assignedAttribute.getName() = shadowedMethod.getName() and
      // Ensure assignment occurs within __init__ method scope
      attributeAssignment.getScope() = parentInitMethod.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// Query to detect obscured methods and corresponding attribute assignments
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
where method_obscured_by_super_attr(childClass, parentClass, attributeAssignment, shadowedMethod)
// Output: shadowed method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"