/**
 * @name Superclass attribute shadows subclass method
 * @description A superclass attribute defined in its __init__ method can shadow a method in a subclass if they have the same name.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies methods in subclasses that are shadowed by attributes defined in superclass __init__ methods
 */

import python

// Determines if a subclass method is shadowed by an attribute in a superclass
predicate shadowed_by_super_class(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // Subclass inherits from superclass
  subclass.getASuperType() = superclass and
  // Subclass declares the method being shadowed
  subclass.declaredAttribute(_) = shadowedMethod and
  // Extract method name for consistent reference
  exists(string methodName |
    methodName = shadowedMethod.getName() and
    // Superclass has an __init__ method that defines the shadowing attribute
    exists(FunctionObject superInit, Attribute assignedAttr |
      // Superclass declares __init__ method
      superclass.declaredAttribute("__init__") = superInit and
      // Attribute assignment targets a self attribute with matching name
      assignedAttr = attributeAssignment.getATarget() and
      assignedAttr.getObject().(Name).getId() = "self" and
      assignedAttr.getName() = methodName and
      // Assignment occurs within superclass __init__ scope
      attributeAssignment.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    ) and
    // Superclass doesn't define a method with the same name
    not superclass.hasAttribute(methodName)
  )
}

// Query results: shadowed method location, descriptive message, and shadowing attribute
from ClassObject c, ClassObject supercls, Assign assign, FunctionObject shadowed
where shadowed_by_super_class(c, supercls, assign, shadowed)
select shadowed.getOrigin(),
  "Method " + shadowed.getName() + " is shadowed by an $@ in super class '" + supercls.getName() +
    "'.", assign, "attribute"