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
  ClassObject parentClass, string methodName, Call problematicCall,
  FunctionObject overridingMethod, FunctionObject baseClassMethod
where
  // Identify parent class with an __init__ method
  exists(FunctionObject initializerMethod |
    parentClass.declaredAttribute("__init__") = initializerMethod and
    // Call occurs within the __init__ method's scope
    problematicCall.getScope() = initializerMethod.getFunction() and
    // Call target is a self-reference (e.g., self.method())
    exists(SelfAttribute selfRef |
      problematicCall.getFunc() = selfRef and
      // Extract method name from self-reference
      selfRef.getName() = methodName and
      // Verify method exists in parent class
      baseClassMethod = parentClass.declaredAttribute(methodName) and
      // Confirm method is overridden by a subclass
      overridingMethod.overrides(baseClassMethod)
    )
  )
// Generate alert with method call details and override information
select problematicCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseClassMethod, methodName, overridingMethod, overridingMethod.descriptiveString()