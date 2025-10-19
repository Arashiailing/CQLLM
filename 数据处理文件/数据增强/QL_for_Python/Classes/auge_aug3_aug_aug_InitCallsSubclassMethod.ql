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

// Identify risky constructor calls where parent class invokes overridable methods
from
  ClassObject superClass, string targetMethodName, Call riskyCall, 
  FunctionObject subclassMethod, FunctionObject superMethod, 
  FunctionObject initMethod, SelfAttribute selfAttr
where
  // Step 1: Establish parent class context and method definitions
  superClass.declaredAttribute("__init__") = initMethod and
  superMethod = superClass.declaredAttribute(targetMethodName) and
  
  // Step 2: Verify method call occurs within constructor scope
  riskyCall.getScope() = initMethod.getFunction() and
  
  // Step 3: Confirm call targets self attribute matching target method
  riskyCall.getFunc() = selfAttr and
  selfAttr.getName() = targetMethodName and
  
  // Step 4: Validate existence of subclass override
  subclassMethod.overrides(superMethod)
// Generate warning for potentially dangerous constructor method call
select riskyCall, "Call to self.$@ in __init__ method, which is overridden by $@.", 
  superMethod, targetMethodName, subclassMethod, subclassMethod.descriptiveString()