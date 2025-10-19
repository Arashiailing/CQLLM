/**
 * @name Superclass attribute shadows subclass method
 * @description Detects instances where an attribute set in a superclass constructor
 *              hides a method implemented in a subclass, which may result in runtime errors
 *              or unintended behavior during program execution.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies methods within subclasses that become inaccessible due to
 * instance variables with matching names being initialized in the superclass constructor.
 * This scenario can cause method invocations to unexpectedly reference attribute values
 * rather than executing the intended method logic.
 */

import python

// Predicate that identifies subclass methods hidden by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject maskedMethod
) {
  // Establish inheritance relationship between the classes
  derivedClass.getASuperType() = baseClass and
  // Verify that the subclass contains the method that gets hidden
  derivedClass.declaredAttribute(_) = maskedMethod and
  // Find the superclass constructor where the hiding attribute is defined
  exists(FunctionObject baseClassInit |
    baseClass.declaredAttribute("__init__") = baseClassInit and
    // Identify the attribute assignment responsible for the hiding effect
    exists(Attribute targetAttribute |
      targetAttribute = attributeAssignment.getATarget() and
      // Confirm the attribute is assigned to 'self' (instance variable)
      targetAttribute.getObject().(Name).getId() = "self" and
      // Ensure the attribute name matches the hidden method name
      targetAttribute.getName() = maskedMethod.getName() and
      // Verify the assignment happens within the constructor's scope
      attributeAssignment.getScope() = baseClassInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude scenarios where the superclass defines a method with the same name
  not baseClass.hasAttribute(maskedMethod.getName())
}

// Primary query to identify and report hidden methods
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject maskedMethod
where isMethodObscuredBySuperclassAttribute(derivedClass, baseClass, attributeAssignment, maskedMethod)
// Output: location of hidden method, detailed message, and location of hiding attribute
select maskedMethod.getOrigin(),
  "Method " + maskedMethod.getName() + " is obscured by an $@ in superclass '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"