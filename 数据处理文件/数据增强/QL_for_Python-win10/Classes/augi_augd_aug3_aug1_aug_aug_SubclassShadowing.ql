/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies situations where an attribute set in a superclass's __init__ method
 *              hides a method defined in a subclass, which may lead to runtime errors or
 *              unexpected behavior when attempting to call the method.
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
 * with the same name being set in the superclass's __init__ method. This can cause
 * method calls to unexpectedly reference attribute values instead of executing the intended
 * method logic, potentially leading to subtle bugs.
 */

import python

// Predicate to identify subclass methods that are masked by attributes in superclass
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject obscuredMethod
) {
  // Establish inheritance relationship
  derivedClass.getASuperType() = baseClass and
  // Verify the subclass declares the method that gets obscured
  derivedClass.declaredAttribute(_) = obscuredMethod and
  // Find the superclass __init__ method where the masking attribute is defined
  exists(FunctionObject superclassInitializer |
    baseClass.declaredAttribute("__init__") = superclassInitializer and
    // Locate the attribute assignment that causes the masking
    exists(Attribute assignedAttribute |
      assignedAttribute = attributeAssignment.getATarget() and
      // Verify the attribute is assigned to 'self' (instance variable)
      assignedAttribute.getObject().(Name).getId() = "self" and
      // Ensure the attribute name matches the obscured method name
      assignedAttribute.getName() = obscuredMethod.getName() and
      // Confirm the assignment happens within the __init__ method's scope
      attributeAssignment.getScope() = superclassInitializer.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where the superclass defines a method with the same name
  not baseClass.hasAttribute(obscuredMethod.getName())
}

// Main query to detect and report obscured methods
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject obscuredMethod
where isMethodObscuredBySuperclassAttribute(derivedClass, baseClass, attributeAssignment, obscuredMethod)
// Output: location of obscured method, detailed message, and location of masking attribute
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"