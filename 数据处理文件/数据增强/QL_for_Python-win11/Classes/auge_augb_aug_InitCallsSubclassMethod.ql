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
  ClassObject parentClass, string methodName, Call selfCall,
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // Identify calls within parent class __init__ methods
  exists(FunctionObject initFunction, SelfAttribute selfExpr |
    parentClass.declaredAttribute("__init__") = initFunction and
    selfCall.getScope() = initFunction.getFunction() and
    selfCall.getFunc() = selfExpr
  |
    // Verify called method exists in parent class and is overridden
    selfExpr.getName() = methodName and
    overriddenMethod = parentClass.declaredAttribute(methodName) and
    overridingMethod.overrides(overriddenMethod)
  )
// Generate alert with method call details and override information
select selfCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  overriddenMethod, methodName, overridingMethod, overridingMethod.descriptiveString()