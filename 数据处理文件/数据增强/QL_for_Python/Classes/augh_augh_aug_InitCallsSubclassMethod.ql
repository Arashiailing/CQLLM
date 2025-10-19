/**
 * @name `__init__` method calls overridden method
 * @description Detects when a superclass's `__init__` method invokes a method that is overridden
 *              by a subclass, potentially exposing a partially initialized object state.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify superclass initializers that call methods overridden by subclasses
from
  ClassObject parentClass, string methodName, Call methodCall,
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // Ensure parent class has an __init__ method
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // Locate the parent class's __init__ method
    parentClass.declaredAttribute("__init__") = initMethod and
    // Verify the method call occurs within __init__'s scope
    methodCall.getScope() = initMethod.getFunction() and
    // Confirm the call targets a self attribute
    methodCall.getFunc() = selfAttr
  |
    // Match the self attribute name to the target method
    selfAttr.getName() = methodName and
    // Retrieve the method as declared in the parent class
    overriddenMethod = parentClass.declaredAttribute(methodName) and
    // Verify a subclass overrides this method
    overridingMethod.overrides(overriddenMethod)
  )
// Generate warning about potentially dangerous method call in __init__
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  overriddenMethod, methodName, overridingMethod, overridingMethod.descriptiveString()