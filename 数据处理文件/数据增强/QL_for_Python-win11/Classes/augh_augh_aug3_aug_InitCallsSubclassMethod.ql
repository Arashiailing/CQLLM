/**
 * @name `__init__` method calls overridden method
 * @description Detects calls to methods overridden by subclasses within `__init__` methods,
 *              which may lead to partially initialized instances being observed.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify problematic calls in parent class __init__ methods
from
  ClassObject parentClass, string methodName, Call callInInit,
  FunctionObject overridingMethod, FunctionObject parentMethod
where
  // Step 1: Verify parent class __init__ method exists and contains the call
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // Locate parent class __init__ method
    parentClass.declaredAttribute("__init__") = initMethod and
    // Confirm call occurs within __init__ method scope
    callInInit.getScope() = initMethod.getFunction() and
    // Verify call targets a self attribute
    callInInit.getFunc() = selfAttr
  |
    // Step 2: Identify method being called and its parent implementation
    selfAttr.getName() = methodName and
    parentMethod = parentClass.declaredAttribute(methodName) and
    // Step 3: Confirm subclass overrides this method
    overridingMethod.overrides(parentMethod)
  )
// Report warning about overridden method call in __init__
select callInInit, "Call to self.$@ in __init__ method, which is overridden by $@.",
  parentMethod, methodName, overridingMethod, overridingMethod.descriptiveString()