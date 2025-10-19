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

// Predicate to detect when a method in a derived class is shadowed by an attribute
// assignment in the base class's __init__ method
predicate shadowed_by_super_class(
  ClassObject derivedClass, ClassObject baseClass, Assign attrAssignStmt, FunctionObject shadowedMethod
) {
  // Establish inheritance relationship between derived and base class
  derivedClass.getASuperType() = baseClass and
  
  // Verify that the derived class declares a method that will be shadowed
  derivedClass.declaredAttribute(_) = shadowedMethod and
  
  // Check that the base class has an __init__ method where the shadowing attribute is defined
  exists(FunctionObject baseInitMethod |
    baseClass.declaredAttribute("__init__") = baseInitMethod and
    
    // Confirm the attribute assignment occurs within the base class's __init__ method scope
    attrAssignStmt.getScope() = baseInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // Identify the specific attribute that shadows the method
  exists(Attribute shadowingAttr |
    shadowingAttr = attrAssignStmt.getATarget() and
    
    // Ensure the attribute is assigned to 'self' (instance attribute)
    shadowingAttr.getObject().(Name).getId() = "self" and
    
    // Match the attribute name with the method name being shadowed
    shadowingAttr.getName() = shadowedMethod.getName()
  ) and
  
  // Exclude cases where the base class defines the same method
  // (to avoid false positives when the method is intentionally overridden)
  not baseClass.hasAttribute(shadowedMethod.getName())
}

// Main query to find all instances of shadowed methods
from ClassObject derivedClass, ClassObject baseClass, Assign attrAssignStmt, FunctionObject shadowedMethod
where shadowed_by_super_class(derivedClass, baseClass, attrAssignStmt, shadowedMethod)
// Display the location of the shadowed method, a descriptive message, and the location of the shadowing attribute
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in superclass '" + baseClass.getName() +
    "'.", attrAssignStmt, "attribute"