/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute set in a superclass __init__ method 
 *              hides a method defined in a subclass, potentially causing runtime errors.
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
 * attributes initialized in the superclass constructor, which could lead to
 * unexpected method resolution behavior.
 */

import python

// Predicate to detect subclass methods hidden by superclass attributes
predicate method_hidden_by_super_attr(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject hiddenMethod
) {
  // Verify inheritance relationship between classes
  subCls.getASuperType() = superCls and
  // Confirm subclass contains the method being hidden
  subCls.declaredAttribute(_) = hiddenMethod and
  // Locate superclass __init__ method containing the hiding attribute
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment within __init__ that hides the method
    exists(Attribute targetAttr |
      targetAttr = attrAssign.getATarget() and
      // Ensure attribute is assigned to 'self'
      targetAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with hidden method name
      targetAttr.getName() = hiddenMethod.getName() and
      // Verify assignment occurs within __init__ method scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superCls.hasAttribute(hiddenMethod.getName())
}

// Query to find hidden methods and their corresponding attribute assignments
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject hiddenMethod
where method_hidden_by_super_attr(subCls, superCls, attrAssign, hiddenMethod)
// Output: hidden method location, descriptive message, attribute assignment location
select hiddenMethod.getOrigin(),
  "Method " + hiddenMethod.getName() + " is hidden by an $@ in superclass '" + superCls.getName() +
    "'.", attrAssign, "attribute"