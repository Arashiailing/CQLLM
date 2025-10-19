/**
 * @name `__init__` method calls overridden method
 * @description Detects calls within `__init__` methods to functions that may be overridden by subclasses,
 *              potentially exposing partially initialized objects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from
  ClassObject superClass, string methodIdentifier, Call initCall,
  FunctionObject subclassMethod, FunctionObject superclassMethod
where
  // Verify the call occurs within a superclass __init__ method
  exists(FunctionObject initMethod, SelfAttribute selfReference |
    superClass.declaredAttribute("__init__") = initMethod and
    initCall.getScope() = initMethod.getFunction() and
    initCall.getFunc() = selfReference
  |
    // Ensure called method exists in superclass and is overridden
    selfReference.getName() = methodIdentifier and
    superclassMethod = superClass.declaredAttribute(methodIdentifier) and
    subclassMethod.overrides(superclassMethod)
  )
// Generate alert with method call details and override information
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superclassMethod, methodIdentifier, subclassMethod, subclassMethod.descriptiveString()