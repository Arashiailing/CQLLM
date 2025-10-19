/**
 * @name `__init__` method calls overridden method
 * @description Detects calls within `__init__` methods to functions that may be overridden by subclasses,
 *              which can lead to exposure of partially initialized objects.
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
  ClassObject parentClass, string methodName, Call methodCallInInit,
  FunctionObject overridingMethod, FunctionObject originalMethod
where
  // Identify the __init__ method of a class
  exists(FunctionObject initMethod, SelfAttribute selfAttribute |
    // Ensure we're working with a class's __init__ method
    parentClass.declaredAttribute("__init__") = initMethod and
    // Check if the call is inside this __init__ method
    methodCallInInit.getScope() = initMethod.getFunction() and
    // Verify the call is to a method on self
    methodCallInInit.getFunc() = selfAttribute
  |
    // Get the name of the called method
    selfAttribute.getName() = methodName and
    // Find the original method in the parent class
    originalMethod = parentClass.declaredAttribute(methodName) and
    // Check if this method is overridden by a subclass
    overridingMethod.overrides(originalMethod)
  )
// Generate an alert with details about the problematic call
select methodCallInInit, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  originalMethod, methodName, overridingMethod, overridingMethod.descriptiveString()