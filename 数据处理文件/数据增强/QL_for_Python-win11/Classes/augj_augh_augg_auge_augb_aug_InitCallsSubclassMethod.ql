/**
 * @name `__init__` method calls overridden method
 * @description Detects when `__init__` methods invoke functions that could be overridden by subclasses,
 *              potentially exposing partially initialized objects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from
  ClassObject superClass, string methodName, Call selfCall,
  FunctionObject subclassMethod, FunctionObject superclassMethod
where
  // Identify the superclass and its initialization method
  exists(FunctionObject initMethod, SelfAttribute selfAttribute |
    // Locate the __init__ method in the superclass
    superClass.declaredAttribute("__init__") = initMethod and
    
    // Find method calls on self within the __init__ method
    selfCall.getScope() = initMethod.getFunction() and
    selfCall.getFunc() = selfAttribute and
    
    // Extract the name of the method being called
    selfAttribute.getName() = methodName and
    
    // Verify the method exists in the superclass
    superclassMethod = superClass.declaredAttribute(methodName) and
    
    // Confirm the method is overridden by a subclass
    subclassMethod.overrides(superclassMethod)
  )
// Generate alert with details about the problematic call
select selfCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superclassMethod, methodName, subclassMethod, subclassMethod.descriptiveString()