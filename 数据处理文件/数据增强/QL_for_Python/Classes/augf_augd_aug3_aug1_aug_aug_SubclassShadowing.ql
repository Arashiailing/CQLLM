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

// Identifies subclass methods masked by superclass attributes
predicate methodObscuredBySuperclassAttribute(
  ClassObject childClass, ClassObject parentClass, 
  Assign maskingAttributeAssignment, FunctionObject obscuredMethod
) {
  // Establish inheritance relationship
  childClass.getASuperType() = parentClass and
  // Verify subclass declares the obscured method
  childClass.declaredAttribute(_) = obscuredMethod and
  // Locate superclass __init__ method with masking attribute
  exists(FunctionObject parentInit |
    parentClass.declaredAttribute("__init__") = parentInit and
    // Find attribute assignment causing masking
    exists(Attribute maskingAttr |
      maskingAttr = maskingAttributeAssignment.getATarget() and
      // Confirm assignment targets 'self' (instance variable)
      maskingAttr.getObject().(Name).getId() = "self" and
      // Ensure attribute name matches obscured method name
      maskingAttr.getName() = obscuredMethod.getName() and
      // Verify assignment occurs within __init__ scope
      maskingAttributeAssignment.getScope() = parentInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines same-named method
  not parentClass.hasAttribute(obscuredMethod.getName())
}

// Main query detecting and reporting obscured methods
from ClassObject childClass, ClassObject parentClass, 
     Assign maskingAttributeAssignment, FunctionObject obscuredMethod
where methodObscuredBySuperclassAttribute(childClass, parentClass, maskingAttributeAssignment, obscuredMethod)
// Output: obscured method location, detailed message, and masking attribute location
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is obscured by an $@ in superclass '" + parentClass.getName() +
    "'.", maskingAttributeAssignment, "attribute"