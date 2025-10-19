/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass's __init__ method 
 *              hides a method defined in a subclass, which can cause unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query finds methods in a subclass that are obscured by attributes set in the 
 * superclass's __init__ method. Such obscuring can lead to unexpected behavior because 
 * the attribute assignment in the superclass's __init__ will replace the method in the subclass.
 */

import python

// Predicate identifying subclass methods obscured by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject obscuredMethod
) {
  // Verify inheritance relationship
  subclass.getASuperType() = superclass and
  // Ensure subclass declares the method being obscured
  subclass.declaredAttribute(_) = obscuredMethod and
  // Locate superclass __init__ method containing the obscuring attribute
  exists(FunctionObject parentInit |
    superclass.declaredAttribute("__init__") = parentInit and
    // Identify attribute assignment within __init__ that obscures the method
    exists(Attribute assignedAttribute |
      assignedAttribute = attributeAssignment.getATarget() and
      // Verify attribute is assigned to 'self'
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Match attribute name with obscured method name
      assignedAttribute.getName() = obscuredMethod.getName() and
      // Confirm assignment occurs within __init__ method scope
      attributeAssignment.getScope() = parentInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superclass.hasAttribute(obscuredMethod.getName())
}

// Query to detect obscured methods and their corresponding attribute assignments
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject obscuredMethod
where method_obscured_by_super_attr(subclass, superclass, attributeAssignment, obscuredMethod)
// Output: obscured method location, descriptive message, attribute assignment location
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"