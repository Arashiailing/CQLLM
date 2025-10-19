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
 * with identical names being set in the superclass's __init__ method. This masking effect can lead to
 * method calls unexpectedly accessing attribute values instead of executing method logic.
 */

import python

// Predicate identifying subclass methods masked by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship
  subCls.getASuperType() = superCls and
  // Verify subclass declares the method being masked
  subCls.declaredAttribute(_) = shadowedMethod and
  // Locate superclass __init__ method where masking attribute is defined
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment causing masking effect
    exists(Attribute assignedAttr |
      assignedAttr = attrAssign.getATarget() and
      // Confirm attribute is assigned to 'self' (instance variable)
      assignedAttr.getObject().(Name).getId() = "self" and
      // Ensure attribute name matches obscured method name
      assignedAttr.getName() = shadowedMethod.getName() and
      // Verify assignment occurs within __init__ method's scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines method with same name
  not superCls.hasAttribute(shadowedMethod.getName())
}

// Main query detecting and reporting obscured methods
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
where isMethodObscuredBySuperclassAttribute(subCls, superCls, attrAssign, shadowedMethod)
// Output: location of obscured method, detailed message, and location of masking attribute
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is obscured by an $@ in superclass '" + superCls.getName() +
    "'.", attrAssign, "attribute"