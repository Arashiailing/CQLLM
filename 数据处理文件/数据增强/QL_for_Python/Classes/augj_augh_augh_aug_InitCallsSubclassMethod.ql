/**
 * @name Superclass `__init__` method invokes overridden method
 * @description Identifies instances where a superclass's `__init__` method calls a method that has been
 *              overridden in a subclass, which may lead to exposing a partially initialized object state.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify superclass initializers that call methods overridden by subclasses
from
  ClassObject superclass, string targetMethodName, Call initMethodCall,
  FunctionObject subclassMethod, FunctionObject superclassMethod
where
  // Verify the superclass has an __init__ method
  exists(FunctionObject initMethod |
    superclass.declaredAttribute("__init__") = initMethod and
    // Ensure the method call occurs within the __init__ method's scope
    initMethodCall.getScope() = initMethod.getFunction()
  )
  and
  // Confirm the call targets a self attribute
  exists(SelfAttribute selfAttr |
    initMethodCall.getFunc() = selfAttr and
    // Match the self attribute name to the target method
    selfAttr.getName() = targetMethodName
  )
  and
  // Retrieve the method as declared in the superclass
  superclassMethod = superclass.declaredAttribute(targetMethodName)
  and
  // Verify a subclass overrides this method
  subclassMethod.overrides(superclassMethod)
// Generate warning about potentially dangerous method call in __init__
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superclassMethod, targetMethodName, subclassMethod, subclassMethod.descriptiveString()