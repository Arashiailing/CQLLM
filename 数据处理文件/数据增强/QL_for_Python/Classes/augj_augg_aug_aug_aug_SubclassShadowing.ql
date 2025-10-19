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
 * This analysis identifies situations where a method in a subclass becomes inaccessible 
 * because an attribute with the same name is assigned in the superclass's __init__ method.
 * This shadowing can cause runtime errors when trying to call the shadowed method.
 */

import python

// Predicate to detect subclass methods hidden by superclass attributes
predicate method_hidden_by_super_attribute(
  ClassObject subClass, ClassObject superClass, Assign hidingAssignment, FunctionObject hiddenMethod
) {
  // Verify inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Ensure the subclass contains the method being hidden
  subClass.declaredAttribute(_) = hiddenMethod and
  // Locate the __init__ method in the superclass where hiding occurs
  exists(FunctionObject superInitMethod |
    superClass.declaredAttribute("__init__") = superInitMethod and
    // Confirm assignment happens within the __init__ method's scope
    hidingAssignment.getScope() = superInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Identify the specific attribute assignment causing the hiding
  exists(Attribute assignedAttr |
    assignedAttr = hidingAssignment.getATarget() and
    // Verify attribute is assigned to 'self' (instance attribute)
    assignedAttr.getObject().(Name).getId() = "self" and
    // Match attribute name with hidden method name
    assignedAttr.getName() = hiddenMethod.getName()
  ) and
  // Exclude cases where superclass defines same method (normal override)
  not superClass.hasAttribute(hiddenMethod.getName())
}

// Query to locate hidden methods and their hiding attributes
from ClassObject subClass, ClassObject superClass, Assign hidingAssignment, FunctionObject hiddenMethod
where method_hidden_by_super_attribute(subClass, superClass, hidingAssignment, hiddenMethod)
// Output: hidden method location, detailed message, hiding attribute location
select hiddenMethod.getOrigin(),
  "Method '" + hiddenMethod.getName() + "' is hidden by an $@ in superclass '" + superClass.getName() +
    "', making it inaccessible through normal attribute access.", hidingAssignment, "attribute assignment"