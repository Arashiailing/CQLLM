/**
 * @name `__init__` method calls overridden method
 * @description Detects calls within `__init__` methods to functions that may be overridden by subclasses,
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
  ClassObject parentClass, string methodName, Call callInInit,
  FunctionObject overridingMethod, FunctionObject originalMethod
where
  // Identify calls within parent class __init__ methods
  exists(FunctionObject initMethod, SelfAttribute selfReference |
    parentClass.declaredAttribute("__init__") = initMethod and
    callInInit.getScope() = initMethod.getFunction() and
    callInInit.getFunc() = selfReference
  |
    // Verify the called method exists in parent class and is overridden
    selfReference.getName() = methodName and
    originalMethod = parentClass.declaredAttribute(methodName) and
    overridingMethod.overrides(originalMethod)
  )
// Generate alert with method call details and override information
select callInInit, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  originalMethod, methodName, overridingMethod, overridingMethod.descriptiveString()