/**
 * @name Superclass attribute shadows subclass method
 * @description Detects scenarios where an attribute initialized in a superclass's __init__ method
 *              masks a method defined in a subclass, potentially causing runtime errors or unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This analysis identifies methods in subclasses that become inaccessible due to attributes
 * with identical names being set in the superclass's __init__ method, which can lead to
 * method calls unexpectedly accessing attribute values instead of executing method logic.
 */

import python

// Predicate that identifies subclass methods masked by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between classes
  subCls.getASuperType() = superCls and
  // Confirm the subclass declares the method that gets obscured
  subCls.declaredAttribute(_) = shadowedMethod and
  // Find the superclass __init__ method where the masking attribute is defined
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Locate the attribute assignment that causes the masking effect
    exists(Attribute assignedAttr |
      assignedAttr = attrAssign.getATarget() and
      // Verify the attribute is assigned to 'self' (instance variable)
      assignedAttr.getObject().(Name).getId() = "self" and
      // Ensure the attribute name matches the obscured method name
      assignedAttr.getName() = shadowedMethod.getName() and
      // Confirm the assignment happens within the __init__ method's scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where the superclass defines a method with the same name
  not superCls.hasAttribute(shadowedMethod.getName())
}

// Main query to detect and report obscured methods
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
where isMethodObscuredBySuperclassAttribute(subCls, superCls, attrAssign, shadowedMethod)
// Output: location of obscured method, detailed message, and location of masking attribute
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + superCls.getName() +
    "'.", attrAssign, "attribute"