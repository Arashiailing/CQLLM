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
  ClassObject superClass, string overriddenMethodName, Call riskyCall, 
  FunctionObject subclassMethod, FunctionObject superMethod, 
  FunctionObject superConstructor, SelfAttribute selfAttr
where
  // Step 1: Obtain parent class constructor and target method
  superClass.declaredAttribute("__init__") = superConstructor and
  superMethod = superClass.declaredAttribute(overriddenMethodName) and
  
  // Step 2: Verify method call occurs within constructor scope
  riskyCall.getScope() = superConstructor.getFunction() and
  
  // Step 3: Confirm call targets self attribute matching method name
  riskyCall.getFunc() = selfAttr and
  selfAttr.getName() = overriddenMethodName and
  
  // Step 4: Ensure subclass overrides parent method
  subclassMethod.overrides(superMethod)
// Generate warning for potentially dangerous constructor method call
select riskyCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superMethod, overriddenMethodName, subclassMethod, subclassMethod.descriptiveString()