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
  ClassObject baseClass, string calledMethodName, Call initMethodCall,
  FunctionObject subMethod, FunctionObject baseMethod
where
  // Identify calls within base class __init__ methods
  exists(FunctionObject initFunction, SelfAttribute selfExpr |
    // Ensure call is inside a base class __init__ method
    baseClass.declaredAttribute("__init__") = initFunction and
    initMethodCall.getScope() = initFunction.getFunction() and
    initMethodCall.getFunc() = selfExpr
  |
    // Verify called method exists in base class and is overridden
    selfExpr.getName() = calledMethodName and
    baseMethod = baseClass.declaredAttribute(calledMethodName) and
    subMethod.overrides(baseMethod)
  )
// Generate alert with method call details and override information
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseMethod, calledMethodName, subMethod, subMethod.descriptiveString()