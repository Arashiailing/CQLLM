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

// Identify cases where parent class constructor invokes methods overridden by subclasses
from
  ClassObject parentClass, string methodName, Call dangerousCall,
  FunctionObject childMethod, FunctionObject parentMethod,
  FunctionObject parentConstructor, SelfAttribute selfAttribute
where
  // Step 1: Obtain parent class constructor and target method
  parentClass.declaredAttribute("__init__") = parentConstructor and
  parentMethod = parentClass.declaredAttribute(methodName) and
  
  // Step 2: Verify method call occurs within constructor scope
  dangerousCall.getScope() = parentConstructor.getFunction() and
  
  // Step 3: Confirm call targets self attribute matching method name
  dangerousCall.getFunc() = selfAttribute and
  selfAttribute.getName() = methodName and
  
  // Step 4: Ensure subclass overrides parent method
  childMethod.overrides(parentMethod)
// Generate warning for potentially dangerous constructor method call
select dangerousCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentMethod, methodName, childMethod, childMethod.descriptiveString()