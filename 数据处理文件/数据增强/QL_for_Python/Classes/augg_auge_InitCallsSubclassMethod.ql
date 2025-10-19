/**
 * @name `__init__` method calls overridden method
 * @description Detects when an `__init__` method calls a method that is overridden by a subclass.
 *              This can lead to a partially initialized instance being observed by the subclass method.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify problematic calls in parent class initializers where a method
// invoked via 'self' is overridden by a subclass method
from
  ClassObject superClass, string methodIdentifier, Call problematicCall,
  FunctionObject overridingMethod, FunctionObject overriddenMethod
where
  // Verify existence of parent class initializer containing a 'self' method call
  exists(FunctionObject initializerMethod, SelfAttribute selfReference |
    // Obtain parent class's __init__ method
    superClass.declaredAttribute("__init__") = initializerMethod and
    // Ensure call occurs within initializer scope
    problematicCall.getScope() = initializerMethod.getFunction() and
    // Confirm call targets a 'self' attribute
    problematicCall.getFunc() = selfReference
  |
    // Match called method name with target identifier
    selfReference.getName() = methodIdentifier and
    // Retrieve method declaration in parent class
    overriddenMethod = superClass.declaredAttribute(methodIdentifier) and
    // Detect subclass method overriding parent method
    overridingMethod.overrides(overriddenMethod)
  )
// Generate warning with method details and override information
select problematicCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, methodIdentifier,
  overridingMethod, overridingMethod.descriptiveString()