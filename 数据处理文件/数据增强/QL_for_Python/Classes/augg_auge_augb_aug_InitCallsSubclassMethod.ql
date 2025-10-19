/**
 * @name `__init__` method calls overridden method
 * @description Identifies when `__init__` methods invoke functions that could be overridden by subclasses,
 *              which may lead to exposure of partially initialized objects.
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
  ClassObject superClass, string methodName, Call selfInvocation,
  FunctionObject subClassMethod, FunctionObject superMethod
where
  // Locate self method calls within superclass __init__ methods
  exists(FunctionObject initializer, SelfAttribute selfRef |
    superClass.declaredAttribute("__init__") = initializer and
    selfInvocation.getScope() = initializer.getFunction() and
    selfInvocation.getFunc() = selfRef and
    // Verify the method exists in superclass and is overridden
    selfRef.getName() = methodName and
    superMethod = superClass.declaredAttribute(methodName) and
    subClassMethod.overrides(superMethod)
  )
// Generate alert with details about the problematic call
select selfInvocation, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superMethod, methodName, subClassMethod, subClassMethod.descriptiveString()