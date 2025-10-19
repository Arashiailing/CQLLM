/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects can be shared across many instances. Mutating them can cause strange side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies classes with descriptor protocol methods that perform mutation operations
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutatingOperation) {
  // Verify the class implements descriptor protocol
  descriptorCls.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string protocolMethodName |
    descriptorCls.lookupAttribute(protocolMethodName) = protocolMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Locate methods called by descriptor protocol methods
    exists(PyFunctionObject calledMethod |
      // Called method belongs to the same class
      descriptorCls.lookupAttribute(_) = calledMethod and
      // Trace call chain from descriptor method to called method
      protocolMethod.getACallee*() = calledMethod and
      // Exclude initialization methods
      not calledMethod.getName() = "__init__" and
      // Mutation occurs within the called method's scope
      mutatingOperation.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify classes and operations where descriptor mutation occurs
from ClassObject descriptorCls, SelfAttributeStore mutatingOperation
where has_descriptor_mutation(descriptorCls, mutatingOperation)
// Output mutation location, warning message, and related class details
select mutatingOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()