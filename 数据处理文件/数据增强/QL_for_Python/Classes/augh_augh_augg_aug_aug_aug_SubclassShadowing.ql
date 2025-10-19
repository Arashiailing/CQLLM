/**
 * @name Superclass attribute shadows subclass method
 * @description Identifies situations where an attribute defined in a superclass's __init__ method 
 *              has the same name as a method in a subclass, rendering the method inaccessible.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis detects methods in subclasses that are hidden by attribute assignments 
 * with identical names in the superclass's __init__ method. This shadowing can cause 
 * runtime errors when trying to invoke the obscured method.
 */

import python

// Predicate identifying subclass methods hidden by superclass attributes
predicate method_hidden_by_super_attribute(
  ClassObject childClass, ClassObject parentClass, Assign obscuringAssignment, FunctionObject obscuredMethod
) {
  // Establish inheritance relationship between classes
  childClass.getASuperType() = parentClass and
  // Confirm the subclass contains the method being hidden
  childClass.declaredAttribute(_) = obscuredMethod and
  // Find the superclass __init__ method where the hiding occurs
  exists(FunctionObject baseInit |
    parentClass.declaredAttribute("__init__") = baseInit and
    // Ensure the assignment happens within the __init__ method's scope
    obscuringAssignment.getScope() = baseInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify the attribute assignment causing the hiding
  exists(Attribute targetAttr |
    targetAttr = obscuringAssignment.getATarget() and
    // Verify the attribute is assigned to 'self' (instance attribute)
    targetAttr.getObject().(Name).getId() = "self" and
    // Match the attribute name with the hidden method's name
    targetAttr.getName() = obscuredMethod.getName()
  ) and
  // Exclude cases where the superclass defines the same method (normal override)
  not parentClass.hasAttribute(obscuredMethod.getName())
}

// Query to find hidden methods and their hiding attributes
from ClassObject childClass, ClassObject parentClass, Assign obscuringAssignment, FunctionObject obscuredMethod
where method_hidden_by_super_attribute(childClass, parentClass, obscuringAssignment, obscuredMethod)
// Output: hidden method location, detailed message, hiding attribute location
select obscuredMethod.getOrigin(),
  "Method '" + obscuredMethod.getName() + "' is hidden by an $@ in superclass '" + parentClass.getName() +
    "', preventing normal access to the method.", obscuringAssignment, "attribute assignment"