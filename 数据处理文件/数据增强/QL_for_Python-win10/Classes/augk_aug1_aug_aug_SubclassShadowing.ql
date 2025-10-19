/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute set in a superclass's __init__ method 
 *              unintentionally hides a method defined in a subclass, potentially causing runtime errors.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query identifies subclass methods that become inaccessible due to 
 * attribute assignments in superclass initializers, which may lead to 
 * unexpected behavior when method resolution order is affected.
 */

import python

// Predicate detecting subclass methods hidden by superclass attributes
predicate method_hidden_by_super_attr(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject hiddenMethod
) {
  // Establish inheritance relationship
  subCls.getASuperType() = superCls and
  // Verify subclass contains the hidden method
  subCls.declaredAttribute(_) = hiddenMethod and
  // Find superclass __init__ containing the shadowing attribute
  exists(FunctionObject superInit |
    superCls.declaredAttribute("__init__") = superInit and
    // Identify attribute assignment that causes shadowing
    exists(Attribute assignedAttr |
      assignedAttr = attrAssign.getATarget() and
      // Confirm assignment targets 'self' instance
      assignedAttr.getObject().(Name).getId() = "self" and
      // Match attribute name with hidden method name
      assignedAttr.getName() = hiddenMethod.getName() and
      // Ensure assignment occurs within __init__ scope
      attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where superclass defines the same method
  not superCls.hasAttribute(hiddenMethod.getName())
}

// Query to identify shadowed methods and their source attributes
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject hiddenMethod
where method_hidden_by_super_attr(subCls, superCls, attrAssign, hiddenMethod)
// Output: hidden method location, detailed message, attribute assignment location
select hiddenMethod.getOrigin(),
  "Method " + hiddenMethod.getName() + " is shadowed by $@ in superclass '" + superCls.getName() +
    "'.", attrAssign, "attribute"