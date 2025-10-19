/**
 * @name Constructor calls overridable method
 * @description Identifies when a class constructor (__init__) invokes a method that may be overridden 
 *              by subclasses, potentially exposing partially initialized objects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Find parent class constructors invoking overridable methods
from
  ClassObject parentClass, string methodName, Call dangerousCall, 
  FunctionObject childMethod, FunctionObject parentMethod, 
  FunctionObject parentConstructor, SelfAttribute selfMethodAttr
where
  // Establish parent class constructor and target method
  parentClass.declaredAttribute("__init__") = parentConstructor and
  parentMethod = parentClass.declaredAttribute(methodName) and
  
  // Verify method call occurs within constructor scope
  dangerousCall.getScope() = parentConstructor.getFunction() and
  
  // Confirm call targets self attribute matching method name
  dangerousCall.getFunc() = selfMethodAttr and
  selfMethodAttr.getName() = methodName and
  
  // Ensure subclass overrides parent method
  childMethod.overrides(parentMethod)
// Report potentially dangerous constructor method invocation
select dangerousCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentMethod, methodName, childMethod, childMethod.descriptiveString()