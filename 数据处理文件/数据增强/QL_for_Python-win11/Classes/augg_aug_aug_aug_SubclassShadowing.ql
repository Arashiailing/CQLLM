/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass's __init__ method 
 *              shadows a method defined in a subclass, potentially causing unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies methods in subclasses that become inaccessible due to 
 * attribute assignments with matching names in the superclass's __init__ method.
 * Such shadowing can lead to runtime errors when attempting to call the shadowed method.
 */

import python

// Predicate to detect subclass methods obscured by superclass attributes
predicate method_obscured_by_super_attribute(
  ClassObject derivedClass, ClassObject baseClass, Assign obscuringAssignment, FunctionObject obscuredMethod
) {
  // Verify inheritance relationship between classes
  derivedClass.getASuperType() = baseClass and
  // Ensure the derived class contains the method being obscured
  derivedClass.declaredAttribute(_) = obscuredMethod and
  // Locate the __init__ method in the base class where obscuring occurs
  exists(FunctionObject baseInitMethod |
    baseClass.declaredAttribute("__init__") = baseInitMethod and
    // Confirm assignment happens within the __init__ method's scope
    obscuringAssignment.getScope() = baseInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify the specific attribute assignment causing the obscuring
  exists(Attribute assignedAttr |
    assignedAttr = obscuringAssignment.getATarget() and
    // Verify attribute is assigned to 'self' (instance attribute)
    assignedAttr.getObject().(Name).getId() = "self" and
    // Match attribute name with obscured method name
    assignedAttr.getName() = obscuredMethod.getName()
  ) and
  // Exclude cases where base class defines same method (normal override)
  not baseClass.hasAttribute(obscuredMethod.getName())
}

// Query to locate obscured methods and their obscuring attributes
from ClassObject derivedClass, ClassObject baseClass, Assign obscuringAssignment, FunctionObject obscuredMethod
where method_obscured_by_super_attribute(derivedClass, baseClass, obscuringAssignment, obscuredMethod)
// Output: obscured method location, detailed message, obscuring attribute location
select obscuredMethod.getOrigin(),
  "Method '" + obscuredMethod.getName() + "' is obscured by an $@ in superclass '" + baseClass.getName() +
    "', making it inaccessible through normal attribute access.", obscuringAssignment, "attribute assignment"