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

// Identify calls in parent __init__ methods to methods overridden by subclasses
from
  ClassObject parentClass, string methodName, Call callInInit,
  FunctionObject overridingMethod, FunctionObject parentMethod
where
  // Verify existence of parent class __init__ method containing the call
  exists(FunctionObject initFunc, SelfAttribute selfMethodAttr |
    // Locate parent class __init__ method
    parentClass.declaredAttribute("__init__") = initFunc and
    // Confirm call occurs within __init__ method scope
    callInInit.getScope() = initFunc.getFunction() and
    // Verify call targets a self attribute
    callInInit.getFunc() = selfMethodAttr
  |
    // Match called method name with self attribute name
    selfMethodAttr.getName() = methodName and
    // Retrieve method definition from parent class
    parentMethod = parentClass.declaredAttribute(methodName) and
    // Confirm existence of subclass overriding the method
    overridingMethod.overrides(parentMethod)
  )
// Report warning about overridden method call in __init__
select callInInit, "Call to self.$@ in __init__ method, which is overridden by $@.",
  parentMethod, methodName, overridingMethod, overridingMethod.descriptiveString()