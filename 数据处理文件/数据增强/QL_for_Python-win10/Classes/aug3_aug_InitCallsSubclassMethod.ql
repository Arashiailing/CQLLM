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
  ClassObject superClass, string calledMethodName, Call initMethodCall,
  FunctionObject subclassMethod, FunctionObject superMethod
where
  // Verify existence of parent class __init__ method containing the call
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // Locate parent class __init__ method
    superClass.declaredAttribute("__init__") = initMethod and
    // Confirm call occurs within __init__ method scope
    initMethodCall.getScope() = initMethod.getFunction() and
    // Verify call targets a self attribute
    initMethodCall.getFunc() = selfAttr
  |
    // Match called method name with self attribute name
    selfAttr.getName() = calledMethodName and
    // Retrieve method definition from parent class
    superMethod = superClass.declaredAttribute(calledMethodName) and
    // Confirm existence of subclass overriding the method
    subclassMethod.overrides(superMethod)
  )
// Report warning about overridden method call in __init__
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.",
  superMethod, calledMethodName, subclassMethod, subclassMethod.descriptiveString()