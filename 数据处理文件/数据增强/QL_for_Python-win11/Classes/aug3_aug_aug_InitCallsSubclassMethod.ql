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

// Identify cases where a parent class constructor invokes a method that is overridden by a subclass
from
  ClassObject parentClass, string methodName, Call methodCall, 
  FunctionObject overriddenMethod, FunctionObject parentMethod, 
  FunctionObject constructorMethod, SelfAttribute selfReference
where
  // Step 1: Obtain the parent class constructor and the target method
  parentClass.declaredAttribute("__init__") = constructorMethod and
  parentMethod = parentClass.declaredAttribute(methodName) and
  
  // Step 2: Verify the method call occurs within the constructor's scope
  methodCall.getScope() = constructorMethod.getFunction() and
  
  // Step 3: Confirm the call is to a self attribute matching the target method name
  methodCall.getFunc() = selfReference and
  selfReference.getName() = methodName and
  
  // Step 4: Ensure a subclass overrides the parent method
  overriddenMethod.overrides(parentMethod)
// Generate warning indicating a potentially dangerous method call in the constructor
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentMethod, methodName, overriddenMethod, overriddenMethod.descriptiveString()