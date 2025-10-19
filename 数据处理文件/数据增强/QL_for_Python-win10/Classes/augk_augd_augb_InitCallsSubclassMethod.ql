/**
 * @name `__init__` method calls overridden method
 * @description Detects calls from `__init__` to methods overridden by subclasses,
 *              which may expose partially initialized instances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Identify calls to overridden methods within __init__ methods
from
  ClassObject baseClass, string targetMethodName, Call initMethodCall,
  FunctionObject originalMethod, FunctionObject subclassMethod
where
  // Step 1: Find __init__ method in base class
  exists(FunctionObject classInitMethod |
    baseClass.declaredAttribute("__init__") = classInitMethod and
    // Step 2: Confirm call occurs within __init__ method scope
    initMethodCall.getScope() = classInitMethod.getFunction() and
    // Step 3: Verify call targets method via self reference
    exists(SelfAttribute selfMethodCall |
      initMethodCall.getFunc() = selfMethodCall and
      selfMethodCall.getName() = targetMethodName
    )
  ) and
  // Step 4: Retrieve original method definition from base class
  originalMethod = baseClass.declaredAttribute(targetMethodName) and
  // Step 5: Validate that subclass method overrides base class method
  subclassMethod.overrides(originalMethod)
// Generate alert with method call details
select initMethodCall, "Call to self.$@ in __init__ method, which is overridden by $@.", originalMethod, targetMethodName,
  subclassMethod, subclassMethod.descriptiveString()