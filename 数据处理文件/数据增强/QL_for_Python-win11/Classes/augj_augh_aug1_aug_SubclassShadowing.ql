/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when a superclass attribute defined in __init__ 
 *              hides a method with the same name in a subclass.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies cases where subclass methods are obscured by attributes 
 * initialized in superclass constructors
 */

import python

// Predicate identifying method shadowing by superclass attributes
predicate isMethodHiddenBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject obscuredMethod
) {
  // Establish inheritance relationship
  childClass.getASuperType() = parentClass and
  
  // Verify subclass declares the obscured method
  childClass.declaredAttribute(_) = obscuredMethod and
  
  // Locate matching attribute assignment in superclass __init__
  exists(FunctionObject initializerMethod, Attribute assignedAttribute |
    // Superclass defines __init__ method
    parentClass.declaredAttribute("__init__") = initializerMethod and
    
    // Attribute assignment target matches our assignment
    assignedAttribute = attributeAssignment.getATarget() and
    
    // Assignment is to self attribute
    assignedAttribute.getObject().(Name).getId() = "self" and
    
    // Attribute name matches subclass method name
    assignedAttribute.getName() = obscuredMethod.getName() and
    
    // Assignment occurs within superclass initializer
    attributeAssignment.getScope() = initializerMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // Exclude intentional method overriding in superclass
  not parentClass.hasAttribute(obscuredMethod.getName())
}

// Query to find shadowed methods and related details
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject obscuredMethod
where isMethodHiddenBySuperAttribute(childClass, parentClass, attributeAssignment, obscuredMethod)
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"