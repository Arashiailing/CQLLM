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

// Identifies subclass methods that are shadowed by attributes defined in superclass __init__
predicate methodObscuredBySuperclassAttribute(
  ClassObject subClass, ClassObject superClass, 
  Assign shadowingAttrAssign, FunctionObject maskedMethod
) {
  // Check inheritance relationship between subclass and superclass
  subClass.getASuperType() = superClass and
  // Verify the subclass declares the method that will be masked
  subClass.declaredAttribute(_) = maskedMethod and
  // Find the superclass __init__ method where the shadowing attribute is defined
  exists(FunctionObject superInit |
    superClass.declaredAttribute("__init__") = superInit and
    // Identify the attribute assignment causing the shadowing effect
    exists(Attribute shadowingAttr |
      shadowingAttr = shadowingAttrAssign.getATarget() and
      // Ensure the assignment is to an instance variable (self.attribute)
      shadowingAttr.getObject().(Name).getId() = "self" and
      // Confirm the attribute name matches the method name being shadowed
      shadowingAttr.getName() = maskedMethod.getName() and
      // Verify the assignment occurs within the __init__ method's scope
      shadowingAttrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  // Exclude cases where the superclass also defines a method with the same name
  not superClass.hasAttribute(maskedMethod.getName())
}

// Main query that detects and reports methods shadowed by superclass attributes
from ClassObject subClass, ClassObject superClass, 
     Assign shadowingAttrAssign, FunctionObject maskedMethod
where methodObscuredBySuperclassAttribute(subClass, superClass, shadowingAttrAssign, maskedMethod)
// Output format: location of masked method, detailed message, location of shadowing attribute
select maskedMethod.getOrigin(),
  "Method " + maskedMethod.getName() + " is obscured by an $@ in superclass '" + superClass.getName() +
    "'.", shadowingAttrAssign, "attribute"