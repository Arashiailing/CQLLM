/**
 * @name `__init__` method calls overridden method
 * @description Identifies when `__init__` methods invoke functions that could be overridden by subclasses,
 *              which may lead to exposure of partially initialized objects.
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
  ClassObject parentClass, string methodIdentifier, Call selfMethodCall,
  FunctionObject overridingMethod, FunctionObject originalMethod
where
  // Step 1: Identify the parent class and its __init__ method
  exists(FunctionObject initializer, SelfAttribute selfRef |
    // Ensure we're examining the __init__ method of a parent class
    parentClass.declaredAttribute("__init__") = initializer and
    
    // Step 2: Locate self method calls within the __init__ method
    selfMethodCall.getScope() = initializer.getFunction() and
    selfMethodCall.getFunc() = selfRef and
    
    // Step 3: Extract the method name being called on self
    selfRef.getName() = methodIdentifier and
    
    // Step 4: Verify the method exists in the parent class
    originalMethod = parentClass.declaredAttribute(methodIdentifier) and
    
    // Step 5: Confirm the method is overridden by a subclass
    overridingMethod.overrides(originalMethod)
  )
// Generate alert with details about the problematic call
select selfMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  originalMethod, methodIdentifier, overridingMethod, overridingMethod.descriptiveString()