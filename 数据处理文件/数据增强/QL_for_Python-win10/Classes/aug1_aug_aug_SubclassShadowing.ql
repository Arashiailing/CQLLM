/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies when an attribute defined in a superclass's __init__ method 
 *              obscures a method defined in a subclass, potentially leading to unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query identifies methods defined in a subclass that are hidden by attributes
 * set within the superclass's __init__ method, which may lead to unexpected behavior.
 */

import python

// Predicate identifying subclass methods obscured by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject childCls, ClassObject parentCls, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // Validate inheritance relationship
  childCls.getASuperType() = parentCls and
  // Ensure subclass declares the method being obscured
  childCls.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the obscuring attribute
  exists(FunctionObject parentInit |
    parentCls.declaredAttribute("__init__") = parentInit and
    // Identify attribute assignment within __init__ that obscures the method
    exists(Attribute assignedAttribute |
      assignedAttribute = attrAssignment.getATarget() and
      // Verify attribute is assigned to 'self'
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Match attribute name with obscured method name
      assignedAttribute.getName() = shadowedMethod.getName() and
      // Confirm assignment occurs within __init__ method scope
      attrAssignment.getScope() = parentInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not parentCls.hasAttribute(shadowedMethod.getName())
}

// Query to detect obscured methods and their corresponding attribute assignments
from ClassObject childCls, ClassObject parentCls, Assign attrAssignment, FunctionObject shadowedMethod
where method_obscured_by_super_attr(childCls, parentCls, attrAssignment, shadowedMethod)
// Output: obscured method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + parentCls.getName() +
    "'.", attrAssignment, "attribute"