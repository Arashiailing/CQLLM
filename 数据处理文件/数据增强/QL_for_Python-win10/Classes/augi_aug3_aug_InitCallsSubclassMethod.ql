/**
 * @name `__init__` method calls overridden method
 * @description Identifies when parent class __init__ methods invoke methods that are 
 *              overridden by subclasses, potentially exposing partially initialized objects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// Detect calls within parent __init__ methods to methods that subclasses override
from
  ClassObject parentClass, string methodName, Call initializationCall,
  FunctionObject overridingMethod, FunctionObject parentMethod
where
  // Verify parent class has an __init__ method containing the problematic call
  exists(FunctionObject initializerMethod, SelfAttribute selfAttribute |
    // Locate the __init__ method in the parent class
    parentClass.declaredAttribute("__init__") = initializerMethod and
    // Confirm the call is within the __init__ method's scope
    initializationCall.getScope() = initializerMethod.getFunction() and
    // Verify the call targets a self attribute
    initializationCall.getFunc() = selfAttribute and
    // Match the called method name with the self attribute name
    selfAttribute.getName() = methodName and
    // Retrieve the method definition from the parent class
    parentMethod = parentClass.declaredAttribute(methodName) and
    // Confirm a subclass exists that overrides this method
    overridingMethod.overrides(parentMethod)
  )
// Report warning about overridden method call in __init__
select initializationCall, "Call to self.$@ in __init__ method, which is overridden by $@.",
  parentMethod, methodName, overridingMethod, overridingMethod.descriptiveString()