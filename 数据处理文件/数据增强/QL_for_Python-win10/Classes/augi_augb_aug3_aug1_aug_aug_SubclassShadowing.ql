/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute initialized in a superclass constructor
 *              masks a method defined in a subclass, potentially causing runtime errors.
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
 * with identical names being set in the superclass constructor, which can lead to
 * method calls unexpectedly accessing attribute values instead of executing method logic.
 */

import python

// Predicate identifying subclass methods masked by superclass attributes
predicate isMethodObscuredBySuperclassAttribute(
  ClassObject subClass, ClassObject superClass, Assign maskingAttrAssign, FunctionObject obscuredMethod
) {
  // Verify inheritance relationship between classes
  subClass.getASuperType() = superClass and
  // Confirm subclass declares the method that gets masked
  subClass.declaredAttribute(_) = obscuredMethod and
  // Locate superclass constructor where masking attribute is defined
  exists(FunctionObject superConstructor |
    superClass.declaredAttribute("__init__") = superConstructor and
    // Identify attribute assignment causing the masking effect
    exists(Attribute attrNode |
      attrNode = maskingAttrAssign.getATarget() and
      // Verify attribute is assigned to 'self' (instance variable)
      attrNode.getObject().(Name).getId() = "self" and
      // Ensure attribute name matches the shadowed method name
      attrNode.getName() = obscuredMethod.getName() and
      // Confirm assignment occurs within constructor scope
      maskingAttrAssign.getScope() = superConstructor.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines a method with same name
  not superClass.hasAttribute(obscuredMethod.getName())
}

// Main query to detect and report shadowed methods
from ClassObject subClass, ClassObject superClass, Assign maskingAttrAssign, FunctionObject obscuredMethod
where isMethodObscuredBySuperclassAttribute(subClass, superClass, maskingAttrAssign, obscuredMethod)
// Output: location of shadowed method, detailed message, and location of masking attribute
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + superClass.getName() +
    "'.", maskingAttrAssign, "attribute"