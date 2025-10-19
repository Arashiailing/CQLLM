/**
 * @name Superclass attribute shadows subclass method
 * @description Detects when attributes in superclass initialization methods
 *              shadow methods defined in subclasses, causing the methods to become inaccessible.
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * Identifies scenarios where subclass methods are shadowed by attributes
 * defined in superclass initialization. This occurs because attribute access
 * takes precedence over method lookup during attribute resolution.
 */

import python

from ClassObject subClass, ClassObject superClass, Assign attributeAssignment, FunctionObject overriddenMethod
where
  // Establish inheritance relationship
  subClass.getASuperType() = superClass and
  
  // Verify subclass contains the potentially shadowed method
  subClass.declaredAttribute(_) = overriddenMethod and
  
  // Locate matching attribute assignment in superclass initializer
  exists(FunctionObject initializerMethod, Attribute assignedAttr |
    // Confirm superclass defines __init__ method
    superClass.declaredAttribute("__init__") = initializerMethod and
    
    // Attribute assignment target matches assignedAttr
    assignedAttr = attributeAssignment.getATarget() and
    
    // Assignment target is 'self' instance
    assignedAttr.getObject().(Name).getId() = "self" and
    
    // Attribute name matches subclass method name
    assignedAttr.getName() = overriddenMethod.getName() and
    
    // Assignment occurs within superclass initializer scope
    attributeAssignment.getScope() = initializerMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // Exclude cases where superclass intentionally defines同名 method
  not superClass.hasAttribute(overriddenMethod.getName())
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attributeAssignment, "attribute"