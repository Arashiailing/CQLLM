/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute initialized in a superclass's __init__ method 
 *              masks a method defined in a subclass, potentially causing runtime issues.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies subclass methods that are hidden by attributes 
 * initialized in the superclass's __init__ method.
 */

import python

// Predicate to find subclass methods masked by superclass attributes
predicate method_obscured_by_super_attr(
  ClassObject childClass, ClassObject parentClass, Assign shadowingAttrAssign, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship
  childClass.getASuperType() = parentClass and
  // Confirm subclass declares the masked method
  childClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method containing the masking attribute
  exists(FunctionObject superInit |
    parentClass.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment in __init__ that causes masking
    exists(Attribute assignedAttr |
      assignedAttr = shadowingAttrAssign.getATarget() and
      // Verify attribute is assigned to 'self'
      assignedAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with masked method name
      assignedAttr.getName() = shadowedMethod.getName() and
      // Ensure assignment occurs within __init__ scope
      shadowingAttrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines same-named method
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// Query to identify masked methods and their corresponding attribute assignments
from ClassObject childClass, ClassObject parentClass, Assign shadowingAttrAssign, FunctionObject shadowedMethod
where method_obscured_by_super_attr(childClass, parentClass, shadowingAttrAssign, shadowedMethod)
// Output: masked method location, descriptive message, attribute assignment location
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + parentClass.getName() +
    "'.", shadowingAttrAssign, "attribute"