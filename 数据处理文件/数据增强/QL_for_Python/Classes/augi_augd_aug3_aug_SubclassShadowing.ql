/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when a subclass method is hidden by an attribute defined in its superclass
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies methods in derived classes that are shadowed by attributes
 * defined in base class constructors. This can lead to unexpected behavior
 * as method calls may be overridden by attribute access.
 */

import python

// Checks if a derived class method is shadowed by a base class attribute
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // Verify inheritance relationship
  derivedClass.getASuperType() = baseClass and
  // Confirm the method exists in the derived class
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // Locate matching attribute assignment in base class constructor
  exists(FunctionObject baseInitMethod, Attribute assignedAttribute |
    // Base class has an __init__ method
    baseClass.declaredAttribute("__init__") = baseInitMethod and
    // Attribute is assigned to 'self'
    assignedAttribute.getObject().(Name).getId() = "self" and
    // Attribute name matches the method name
    assignedAttribute.getName() = overriddenMethod.getName() and
    // Assignment occurs within base class constructor
    attributeAssignment.getScope() = baseInitMethod.getOrigin().(FunctionExpr).getInnerScope() and
    // Attribute is the target of the assignment
    assignedAttribute = attributeAssignment.getATarget()
  ) and
  // Exclude cases where base class intentionally defines the method
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// Query for shadowed methods with related context
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
where isMethodShadowedBySuperAttribute(derivedClass, baseClass, attributeAssignment, overriddenMethod)
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in base class '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"