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

// Identify potentially dangerous method calls within class constructors
// that could be overridden by subclasses, leading to initialization issues
from
  ClassObject superClass, string targetMethodName, Call riskyConstructorCall,
  FunctionObject overriddenMethod, FunctionObject baseMethod,
  FunctionObject classConstructor, SelfAttribute instanceMethodRef
where
  // Locate the parent class constructor and identify the method being called
  superClass.declaredAttribute("__init__") = classConstructor and
  baseMethod = superClass.declaredAttribute(targetMethodName) and
  
  // Verify the method call occurs inside the constructor's scope
  riskyConstructorCall.getScope() = classConstructor.getFunction() and
  
  // Confirm the call is to a self attribute that matches our target method
  riskyConstructorCall.getFunc() = instanceMethodRef and
  instanceMethodRef.getName() = targetMethodName and
  
  // Ensure a subclass exists that overrides this parent method
  overriddenMethod.overrides(baseMethod)
// Report the risky constructor call with details about the overridden method
select riskyConstructorCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  baseMethod, targetMethodName, overriddenMethod, overriddenMethod.descriptiveString()