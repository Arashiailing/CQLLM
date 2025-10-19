/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute assigned in a superclass's __init__ 
 *              shares the name with a subclass method, making the method unreachable.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies subclass methods that become inaccessible due to 
 * attribute assignments with matching names in the superclass's __init__ method.
 * Such shadowing can lead to runtime errors when attempting to call the hidden method.
 */

import python

// Predicate identifying subclass methods obscured by superclass attributes
predicate method_hidden_by_super_attribute(
  ClassObject derivedClass, ClassObject baseClass, Assign shadowingAssign, FunctionObject hiddenMethod
) {
  // Verify inheritance relationship between classes
  derivedClass.getASuperType() = baseClass and
  // Confirm the method exists in the subclass
  derivedClass.declaredAttribute(_) = hiddenMethod and
  // Identify attribute assignment causing the shadowing
  exists(Attribute shadowedAttr |
    shadowedAttr = shadowingAssign.getATarget() and
    // Ensure assignment targets 'self' (instance attribute)
    shadowedAttr.getObject().(Name).getId() = "self" and
    // Match attribute name with hidden method name
    shadowedAttr.getName() = hiddenMethod.getName()
  ) and
  // Locate the superclass __init__ method containing the shadowing assignment
  exists(FunctionObject baseInit |
    baseClass.declaredAttribute("__init__") = baseInit and
    // Verify assignment occurs within __init__ method scope
    shadowingAssign.getScope() = baseInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude legitimate method overrides (superclass defines same method)
  not baseClass.hasAttribute(hiddenMethod.getName())
}

// Query to locate hidden methods and their shadowing assignments
from ClassObject derivedClass, ClassObject baseClass, Assign shadowingAssign, FunctionObject hiddenMethod
where method_hidden_by_super_attribute(derivedClass, baseClass, shadowingAssign, hiddenMethod)
// Output: hidden method location, detailed message, shadowing assignment location
select hiddenMethod.getOrigin(),
  "Method '" + hiddenMethod.getName() + "' is hidden by an $@ in superclass '" + baseClass.getName() +
    "', preventing normal access to the method.", shadowingAssign, "attribute assignment"