/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when an attribute defined in a superclass's __init__ method 
 *              shadows a method defined in a subclass, potentially causing unexpected behavior.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * This query identifies methods in subclasses that are shadowed by attributes 
 * defined in the superclass's __init__ method. Such shadowing can lead to unexpected
 * behavior where the method becomes inaccessible due to being replaced by an attribute.
 */

import python

// Predicate to detect when a method in a child class is shadowed by an attribute
// assignment in the parent class's __init__ method
predicate shadowed_by_super_class(
  ClassObject childClass, ClassObject parentClass, Assign attrAssignment, FunctionObject overriddenMethod
) {
  // Ensure child class inherits from parent class
  childClass.getASuperType() = parentClass and
  
  // Verify the child class declares the method that will be shadowed
  childClass.declaredAttribute(_) = overriddenMethod and
  
  // Check that the parent class has an __init__ method where the shadowing attribute is defined
  exists(FunctionObject parentInitMethod |
    parentClass.declaredAttribute("__init__") = parentInitMethod and
    
    // Confirm the attribute assignment occurs within the parent's __init__ method scope
    attrAssignment.getScope() = parentInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // Identify the specific attribute that shadows the method
  exists(Attribute overridingAttr |
    overridingAttr = attrAssignment.getATarget() and
    
    // Ensure the attribute is assigned to 'self' (instance attribute)
    overridingAttr.getObject().(Name).getId() = "self" and
    
    // Match the attribute name with the method name being shadowed
    overridingAttr.getName() = overriddenMethod.getName()
  ) and
  
  // Exclude cases where the parent class defines the same method
  // (to avoid false positives when the method is intentionally overridden)
  not parentClass.hasAttribute(overriddenMethod.getName())
}

// Main query to find all instances of shadowed methods
from ClassObject childClass, ClassObject parentClass, Assign attrAssignment, FunctionObject overriddenMethod
where shadowed_by_super_class(childClass, parentClass, attrAssignment, overriddenMethod)
// Display the location of the shadowed method, a descriptive message, and the location of the shadowing attribute
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in superclass '" + parentClass.getName() +
    "'.", attrAssignment, "attribute"