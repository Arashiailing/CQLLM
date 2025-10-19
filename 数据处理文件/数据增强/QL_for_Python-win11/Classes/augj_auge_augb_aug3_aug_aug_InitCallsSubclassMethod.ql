/**
 * @name Constructor calls overridable method
 * @description Identifies potentially unsafe scenarios where a superclass constructor invokes
 *              a method that can be overridden by subclasses, risking exposure of partially
 *              initialized objects to subclass implementations.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Analyze constructor calls to overridable methods that may expose partially initialized objects
from
  ClassObject superClass, string targetMethodName, Call riskyConstructorCall,
  FunctionObject subclassMethod, FunctionObject superMethod,
  FunctionObject superConstructor, SelfAttribute selfMethodCall
where
  // Establish the superclass constructor and the method being called
  superClass.declaredAttribute("__init__") = superConstructor and
  superMethod = superClass.declaredAttribute(targetMethodName) and
  
  // Verify the method call originates from within the constructor
  riskyConstructorCall.getScope() = superConstructor.getFunction() and
  
  // Confirm the call is made to self and targets the specific method
  riskyConstructorCall.getFunc() = selfMethodCall and
  selfMethodCall.getName() = targetMethodName and
  
  // Ensure the method is overridden by at least one subclass
  subclassMethod.overrides(superMethod)
// Report the potentially dangerous constructor method invocation
select riskyConstructorCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superMethod, targetMethodName, subclassMethod, subclassMethod.descriptiveString()