/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies situations where an attribute initialized in a superclass constructor
 *              masks a method defined in a subclass, potentially causing runtime errors or unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis detects methods in subclasses that become inaccessible due to attributes
 * with identical names being set in the superclass constructor, which can lead to
 * method calls unexpectedly accessing attribute values instead of executing method logic.
 */

import python

// Predicate identifying subclass methods masked by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attrAssign, FunctionObject shadowedMethod
) {
  // Verify inheritance relationship between classes
  childClass.getASuperType() = parentClass and
  // Confirm subclass declares the method that gets masked
  childClass.declaredAttribute(_) = shadowedMethod and
  // Locate superclass constructor where masking attribute is defined
  exists(FunctionObject parentInit |
    parentClass.declaredAttribute("__init__") = parentInit and
    // Identify attribute assignment causing the masking effect
    exists(Attribute assignedAttribute |
      assignedAttribute = attrAssign.getATarget() and
      // Verify attribute is assigned to 'self' (instance variable)
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Ensure attribute name matches the shadowed method name
      assignedAttribute.getName() = shadowedMethod.getName() and
      // Confirm assignment occurs within constructor scope
      attrAssign.getScope() = parentInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines a method with same name
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// Main query to detect and report shadowed methods
from ClassObject childClass, ClassObject parentClass, Assign attrAssign, FunctionObject shadowedMethod
where isMethodObscuredBySuperclassAttribute(childClass, parentClass, attrAssign, shadowedMethod)
// Output: location of shadowed method, detailed message, and location of masking attribute
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + parentClass.getName() +
    "'.", attrAssign, "attribute"