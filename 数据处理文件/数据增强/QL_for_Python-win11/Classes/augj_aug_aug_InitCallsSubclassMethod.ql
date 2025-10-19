/**
 * @name Constructor calls overridable method
 * @description Identifies when a class constructor invokes a method that could be overridden 
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

// Detect parent class constructors invoking overridable methods
from
  ClassObject parentClass, string methodName, Call methodCall,
  FunctionObject overriddenMethod, FunctionObject parentMethod,
  FunctionObject constructor, SelfAttribute selfReference
where
  // Identify parent class constructor
  parentClass.declaredAttribute("__init__") = constructor and
  // Verify call occurs within constructor scope
  methodCall.getScope() = constructor.getFunction() and
  // Confirm call targets a self-referenced method
  methodCall.getFunc() = selfReference and
  // Match method name to called attribute
  selfReference.getName() = methodName and
  // Locate method declaration in parent class
  parentMethod = parentClass.declaredAttribute(methodName) and
  // Ensure subclass overrides the parent method
  overriddenMethod.overrides(parentMethod)
// Report constructor invocation of overridable method
select methodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  parentMethod, methodName, overriddenMethod, overriddenMethod.descriptiveString()