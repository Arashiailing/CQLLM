/**
 * @name Superclass Attribute Shadows Subclass Method
 * @description Detects instances where an attribute in a superclass has the same name as a method in a subclass, effectively shadowing the method
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies cases where:
 * 1. A subclass defines a method
 * 2. A superclass defines an attribute with identical name in its __init__ method
 * 3. The superclass does not have a method with this name
 * Such shadowing can lead to unexpected behavior and bugs.
 */

import python

// Determines if a subclass method is shadowed by superclass attribute
predicate isMethodShadowedBySuperAttr(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject obscuredMethod
) {
  // Verify inheritance relationship
  childClass.getASuperType() = parentClass and
  // Ensure subclass contains the method
  childClass.declaredAttribute(_) = obscuredMethod and
  // Check superclass defines attribute in __init__
  exists(FunctionObject constructorMethod, Attribute attribute |
    // Superclass has __init__ method
    parentClass.declaredAttribute("__init__") = constructorMethod and
    // Assignment targets a self attribute
    attribute = attributeAssignment.getATarget() and
    // Verify assignment to self instance
    attribute.getObject().(Name).getId() = "self" and
    // Attribute name matches method name
    attribute.getName() = obscuredMethod.getName() and
    // Assignment occurs in superclass __init__ scope
    attributeAssignment.getScope() = constructorMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Confirm superclass doesn't define method with same name
  not parentClass.hasAttribute(obscuredMethod.getName())
}

// Identify shadowed methods and related components
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject obscuredMethod
// Apply shadowing detection logic
where isMethodShadowedBySuperAttr(childClass, parentClass, attributeAssignment, obscuredMethod)
// Output results with method location, message, attribute location, and type label
select obscuredMethod.getOrigin(),
  "Method '" + obscuredMethod.getName() + "' is shadowed by $@ in superclass '" + parentClass.getName() + 
    "'.", attributeAssignment, "attribute definition"