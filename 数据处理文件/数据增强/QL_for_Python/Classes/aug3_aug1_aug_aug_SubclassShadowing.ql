/**
 * @name Superclass attribute shadows subclass method
 * @description Detects scenarios where an attribute initialized in a superclass's __init__ method
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
 * This analysis identifies methods in subclasses that become inaccessible due to attributes
 * with identical names being set in the superclass's __init__ method, which can lead to
 * method calls unexpectedly accessing attribute values instead of executing method logic.
 */

import python

// Predicate that identifies subclass methods masked by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject subClass, ClassObject superClass, Assign attributeAssignment, FunctionObject obscuredMethod
) {
  // Establish inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Confirm the subclass declares the method that gets obscured
  subClass.declaredAttribute(_) = obscuredMethod and
  // Find the superclass __init__ method where the masking attribute is defined
  exists(FunctionObject superInit |
    superClass.declaredAttribute("__init__") = superInit and
    // Locate the attribute assignment that causes the masking effect
    exists(Attribute assignedAttr |
      assignedAttr = attributeAssignment.getATarget() and
      // Verify the attribute is assigned to 'self' (instance variable)
      assignedAttr.getObject().(Name).getId() = "self" and
      // Ensure the attribute name matches the obscured method name
      assignedAttr.getName() = obscuredMethod.getName() and
      // Confirm the assignment happens within the __init__ method's scope
      attributeAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where the superclass defines a method with the same name
  not superClass.hasAttribute(obscuredMethod.getName())
}

// Main query to detect and report obscured methods
from ClassObject subClass, ClassObject superClass, Assign attributeAssignment, FunctionObject obscuredMethod
where isMethodObscuredBySuperclassAttribute(subClass, superClass, attributeAssignment, obscuredMethod)
// Output: location of obscured method, detailed message, and location of masking attribute
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + superClass.getName() +
    "'.", attributeAssignment, "attribute"