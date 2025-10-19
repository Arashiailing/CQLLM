/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass has the same name as a method in a subclass,
 *              causing the subclass method to be hidden and potentially leading to unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/* Identifies scenarios where subclass methods are shadowed by superclass attributes:
   when a superclass assigns an attribute in its __init__ method that shares the name
   with a method defined in a subclass, the subclass method becomes inaccessible */
import python

// Query to detect subclass methods being shadowed by superclass attributes
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
where 
  // Establish inheritance relationship: subclass extends superclass
  subclass.getASuperType() = superclass and
  // Subclass declares the method that gets shadowed
  subclass.declaredAttribute(_) = shadowedMethod and
  // Verify superclass __init__ method contains attribute assignment with same name
  exists(FunctionObject initMethod, Attribute targetAttribute |
    // Superclass defines an __init__ method
    superclass.declaredAttribute("__init__") = initMethod and
    // The assignment targets an attribute
    targetAttribute = attributeAssignment.getATarget() and
    // The attribute is assigned to the self object
    targetAttribute.getObject().(Name).getId() = "self" and
    // Attribute name matches the shadowed method name
    targetAttribute.getName() = shadowedMethod.getName() and
    // Assignment occurs within the superclass initialization method
    attributeAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // Exclude cases where superclass intentionally defines same-named method
  not superclass.hasAttribute(shadowedMethod.getName())
// Select the shadowed method location, error message, attribute assignment location, and attribute type
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in superclass '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"