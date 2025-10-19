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

// Identify cases where a superclass constructor invokes a method that is overridden by a subclass
from
  ClassObject superClass, string targetMethodName, Call riskyCall, 
  FunctionObject subclassMethod, FunctionObject superClassMethod, 
  FunctionObject initMethod, SelfAttribute selfAttr
where
  // Step 1: Obtain the superclass constructor and the target method
  superClass.declaredAttribute("__init__") = initMethod and
  superClassMethod = superClass.declaredAttribute(targetMethodName) and
  
  // Step 2: Verify the method call occurs within the constructor's scope
  riskyCall.getScope() = initMethod.getFunction() and
  
  // Step 3: Confirm the call is to a self attribute matching the target method name
  riskyCall.getFunc() = selfAttr and
  selfAttr.getName() = targetMethodName and
  
  // Step 4: Ensure a subclass overrides the superclass method
  subclassMethod.overrides(superClassMethod)
// Generate warning indicating a potentially dangerous method call in the constructor
select riskyCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superClassMethod, targetMethodName, subclassMethod, subclassMethod.descriptiveString()