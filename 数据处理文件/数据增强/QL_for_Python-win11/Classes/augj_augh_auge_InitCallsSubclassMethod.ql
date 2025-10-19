/**
 * @name `__init__` method calls overridden method
 * @description Detects when an `__init__` method calls a method that is overridden by a subclass.
 *              This can lead to a partially initialized instance being observed by the subclass method,
 *              potentially causing unexpected behavior or errors.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify parent classes with __init__ methods that call methods potentially overridden by subclasses
from
  ClassObject parentClass, string methodName, Call initCall,
  FunctionObject subclassMethod, FunctionObject parentMethod,
  FunctionObject initializer, SelfAttribute selfRef
where
  // Parent class must have an __init__ method
  parentClass.declaredAttribute("__init__") = initializer and
  // Call must occur within the __init__ method's scope
  initCall.getScope() = initializer.getFunction() and
  // Call target must be a self attribute
  initCall.getFunc() = selfRef and
  // Called method name must match the attribute name
  selfRef.getName() = methodName and
  // Parent class must declare the called method
  parentMethod = parentClass.declaredAttribute(methodName) and
  // A subclass method must override the parent method
  subclassMethod.overrides(parentMethod)
// Report the problematic call with method details
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", parentMethod, methodName,
  subclassMethod, subclassMethod.descriptiveString()