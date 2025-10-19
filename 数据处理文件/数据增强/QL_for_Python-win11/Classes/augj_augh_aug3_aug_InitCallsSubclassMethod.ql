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

/*
 * This query identifies a specific anti-pattern in Python class initialization:
 * When a parent class's __init__ method calls a method that is overridden by a subclass,
 * it can lead to the subclass method being called before the subclass's own __init__
 * has completed, potentially causing access to uninitialized attributes.
 * 
 * The query works by:
 * 1. Finding parent classes with __init__ methods
 * 2. Identifying calls to self methods within these __init__ methods
 * 3. Checking if these methods are overridden by any subclass
 * 4. Reporting these potentially problematic calls
 */

// Identify calls in parent __init__ methods to methods overridden by subclasses
from
  ClassObject baseClass, string methodName, Call initCall,
  FunctionObject overridingMethod, FunctionObject parentMethod
where
  // Verify existence of parent class __init__ method containing the call
  exists(FunctionObject initFunc, SelfAttribute selfMethodAttr |
    // Locate parent class __init__ method
    baseClass.declaredAttribute("__init__") = initFunc and
    // Confirm call occurs within __init__ method scope
    initCall.getScope() = initFunc.getFunction() and
    // Verify call targets a self attribute
    initCall.getFunc() = selfMethodAttr
  |
    // Match called method name with self attribute name
    selfMethodAttr.getName() = methodName and
    // Retrieve method definition from parent class
    parentMethod = baseClass.declaredAttribute(methodName) and
    // Confirm existence of subclass overriding the method
    overridingMethod.overrides(parentMethod)
  )
// Report warning about overridden method call in __init__
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.",
  parentMethod, methodName, overridingMethod, overridingMethod.descriptiveString()