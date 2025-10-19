/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies when an attribute defined in a superclass shadows a method with the same name in a subclass
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query detects methods in subclasses that are overshadowed by attributes in superclasses:
 * 1. A method is defined in a subclass
 * 2. An attribute with the same name is defined in the superclass's __init__ method
 * 3. The superclass does not define a method with the same name
 */

import python

// Checks if a method in a derived class is shadowed by an attribute in its base class
predicate is_shadowed_by_superclass_attribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // Establish inheritance relationship
  derivedClass.getASuperType() = baseClass and
  // Confirm the derived class declares the method
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // Verify attribute definition in base class initializer
  exists(FunctionObject initializerMethod, Attribute targetAttribute |
    // Base class must have an __init__ method
    baseClass.declaredAttribute("__init__") = initializerMethod and
    // Assignment target must be a self attribute
    targetAttribute = attributeAssignment.getATarget() and
    // Ensure assignment is to a self instance
    targetAttribute.getObject().(Name).getId() = "self" and
    // Attribute name matches the method name
    targetAttribute.getName() = overriddenMethod.getName() and
    // Assignment occurs within base class's __init__ scope
    attributeAssignment.getScope() = initializerMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where base class defines a method with the same name
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// Query to identify shadowed methods and related components
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
// Apply the shadowing detection predicate
where is_shadowed_by_superclass_attribute(derivedClass, baseClass, attributeAssignment, overriddenMethod)
// Output results: method location, descriptive message, attribute assignment location, and type label
select overriddenMethod.getOrigin(),
  "Method '" + overriddenMethod.getName() + "' is shadowed by $@ in superclass '" + baseClass.getName() + 
    "'.", attributeAssignment, "attribute definition"