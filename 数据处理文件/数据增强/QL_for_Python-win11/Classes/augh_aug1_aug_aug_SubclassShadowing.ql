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
 * This query detects a situation where a method in a subclass is hidden by an attribute
 * set in the superclass's __init__ method. This occurs because the attribute assignment
 * in the superclass creates an instance attribute with the same name as the subclass method,
 * effectively obscuring the method when accessed via an instance of the subclass.
 * Such hiding can lead to unexpected behavior and is considered a code smell.
 */

import python

// Predicate identifying subclass methods obscured by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject hiddenMethod
) {
  // Validate inheritance relationship between subclass and superclass
  subClass.getASuperType() = superClass and
  // Ensure subclass declares the method being obscured
  subClass.declaredAttribute(_) = hiddenMethod and
  // Locate superclass __init__ method containing the obscuring attribute
  exists(FunctionObject superInit |
    superClass.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment within __init__ that obscures the method
    exists(Attribute attr |
      attr = attrAssign.getATarget() and
      // Verify attribute is assigned to 'self'
      attr.getObject().(Name).getId() = "self" and
      // Match attribute name with obscured method name
      attr.getName() = hiddenMethod.getName() and
      // Confirm assignment occurs within __init__ method scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method (would be overriding, not shadowing)
  not superClass.hasAttribute(hiddenMethod.getName())
}

// Query to detect obscured methods and their corresponding attribute assignments
from ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject hiddenMethod
where method_obscured_by_super_attr(subClass, superClass, attrAssign, hiddenMethod)
// Output: obscured method location, descriptive message, attribute assignment location
select hiddenMethod.getOrigin(),
  "Method " + hiddenMethod.getName() + " is obscured by an $@ in superclass '" + superClass.getName() +
    "'.", attrAssign, "attribute"