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
  ClassObject baseClass, string calledMethodName, Call initCall,
  FunctionObject subclassMethod, FunctionObject baseClassMethod,
  FunctionObject initMethod, SelfAttribute selfRef
where
  // Identify base class with an __init__ method
  baseClass.declaredAttribute("__init__") = initMethod and
  // Call occurs within the __init__ method's scope
  initCall.getScope() = initMethod.getFunction() and
  // Call target is a self-reference (e.g., self.method())
  initCall.getFunc() = selfRef and
  // Extract method name from self-reference
  selfRef.getName() = calledMethodName and
  // Verify method exists in base class
  baseClassMethod = baseClass.declaredAttribute(calledMethodName) and
  // Confirm method is overridden by a subclass
  subclassMethod.overrides(baseClassMethod)
// Generate alert with method call details and override information
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseClassMethod, calledMethodName, subclassMethod, subclassMethod.descriptiveString()