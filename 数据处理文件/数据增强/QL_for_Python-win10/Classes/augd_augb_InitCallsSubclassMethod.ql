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

// Identify parent class, method name, and call context
from
  ClassObject superClass, string calledMethodName, Call initCall,
  FunctionObject overriddenMethod, FunctionObject overridingMethod
where
  // Step 1: Locate parent class __init__ method
  exists(FunctionObject initMethod |
    superClass.declaredAttribute("__init__") = initMethod and
    // Step 2: Verify call occurs within __init__ method
    initCall.getScope() = initMethod.getFunction() and
    // Step 3: Confirm call targets self attribute
    exists(SelfAttribute selfAttr |
      initCall.getFunc() = selfAttr and
      selfAttr.getName() = calledMethodName
    )
  ) and
  // Step 4: Retrieve parent class method definition
  overriddenMethod = superClass.declaredAttribute(calledMethodName) and
  // Step 5: Validate subclass override relationship
  overridingMethod.overrides(overriddenMethod)
// Generate alert with method details
select initCall, "Call to self.$@ in __init__ method, which is overridden by $@.", overriddenMethod, calledMethodName,
  overridingMethod, overridingMethod.descriptiveString()