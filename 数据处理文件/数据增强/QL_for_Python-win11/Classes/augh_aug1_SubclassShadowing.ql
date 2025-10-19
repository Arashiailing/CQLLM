/**
 * @name Superclass attribute shadows subclass method
 * @description An attribute defined in a superclass's __init__ method can shadow a method
 *              in a subclass if they share the same name, potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Detection scenario: Methods defined in subclasses are shadowed by attributes
 * defined in their superclasses.
 * Key logic:
 * 1. Establish inheritance relationship between subclass and superclass
 * 2. Verify that the superclass defines an attribute with the same name in its __init__ method
 * 3. Ensure the superclass itself doesn't define a method with the same name
 */

import python

// Detects when a subclass method is shadowed by a superclass attribute
predicate shadowed_by_super_class(
  ClassObject subclass, ClassObject superclass, Assign shadowingAttribute, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship
  subclass.getASuperType() = superclass and
  // Verify the method exists in the subclass
  subclass.declaredAttribute(_) = shadowedMethod and
  // Check for shadowing attribute in superclass's __init__ method
  hasShadowingAttributeInInit(superclass, shadowingAttribute, shadowedMethod.getName()) and
  // Exclude cases where superclass defines the same method
  not superclass.hasAttribute(shadowedMethod.getName())
}

// Helper predicate to check if a superclass has a shadowing attribute in its __init__ method
predicate hasShadowingAttributeInInit(
  ClassObject superclass, Assign shadowingAttribute, string methodName
) {
  exists(FunctionObject superInit, Attribute attr |
    // Superclass must define __init__ method
    superclass.declaredAttribute("__init__") = superInit and
    // The assignment targets an attribute
    attr = shadowingAttribute.getATarget() and
    // Attribute must belong to self object
    attr.getObject().(Name).getId() = "self" and
    // Attribute name matches method name
    attr.getName() = methodName and
    // Assignment must occur within the scope of superclass's __init__ method
    shadowingAttribute.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  )
}

// Main query: Identify shadowed methods
from ClassObject subclass, ClassObject superclass, Assign shadowingAttribute, FunctionObject shadowedMethod
where shadowed_by_super_class(subclass, superclass, shadowingAttribute, shadowedMethod)
// Output format remains unchanged: method location + description + shadowing assignment location + attribute type
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by an $@ in superclass '" + superclass.getName() +
    "'.", shadowingAttribute, "attribute"