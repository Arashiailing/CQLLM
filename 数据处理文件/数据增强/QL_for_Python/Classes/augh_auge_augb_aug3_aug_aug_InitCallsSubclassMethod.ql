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

// Identify dangerous constructor calls to overridable methods
from
  ClassObject superClass, string overriddenMethodName, Call problematicCall,
  FunctionObject overridingMethod, FunctionObject overriddenMethod,
  FunctionObject superConstructor, SelfAttribute selfAttr
where
  // Step 1: Establish superclass constructor and target method relationship
  superClass.declaredAttribute("__init__") = superConstructor and
  overriddenMethod = superClass.declaredAttribute(overriddenMethodName) and
  
  // Step 2: Verify method call occurs within constructor scope
  problematicCall.getScope() = superConstructor.getFunction() and
  
  // Step 3: Confirm call targets self attribute matching method name
  problematicCall.getFunc() = selfAttr and
  selfAttr.getName() = overriddenMethodName and
  
  // Step 4: Ensure subclass overrides parent method
  overridingMethod.overrides(overriddenMethod)
// Report potentially dangerous constructor method call
select problematicCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  overriddenMethod, overriddenMethodName, overridingMethod, overridingMethod.descriptiveString()