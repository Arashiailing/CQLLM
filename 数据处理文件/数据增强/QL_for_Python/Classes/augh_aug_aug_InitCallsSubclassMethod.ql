/**
 * @name Constructor calls overridable method
 * @description Detects when a class's `__init__` method invokes another method that can be overridden 
 *              by subclasses, which may lead to observing a partially initialized object.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify cases where a parent class's constructor invokes a method that is overridden by a subclass
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject overriddenMethod, FunctionObject originalMethod, 
  FunctionObject constructorMethod, SelfAttribute selfReference
where
  // Ensure we have a parent class with a constructor
  parentClass.declaredAttribute("__init__") = constructorMethod and
  // Verify the method call occurs within the constructor's scope
  methodCall.getScope() = constructorMethod.getFunction() and
  // Confirm the call is made through a self reference
  methodCall.getFunc() = selfReference and
  // Check that the self reference matches the target method name
  selfReference.getName() = methodName and
  // Retrieve the original method as declared in the parent class
  originalMethod = parentClass.declaredAttribute(methodName) and
  // Ensure there exists a subclass that overrides this method
  overriddenMethod.overrides(originalMethod)
// Output warning indicating a call to an overridden method in the constructor
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  originalMethod, methodName, overriddenMethod, overriddenMethod.descriptiveString()