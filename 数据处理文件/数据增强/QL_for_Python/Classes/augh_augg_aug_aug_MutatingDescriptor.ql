/**
 * @name Mutation of descriptor in `__get__` or `__set__` method
 * @description Descriptor objects are often shared across instances. Mutating them can cause 
 *              unexpected side effects or race conditions due to shared state.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes with state mutations in their protocol methods
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Locate descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    descriptorClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Trace methods invoked within descriptor protocol methods
    exists(PyFunctionObject calledMethod |
      // Ensure called method belongs to the same descriptor class
      descriptorClass.lookupAttribute(_) = calledMethod and
      // Follow call chain from descriptor method to invoked method
      descriptorMethod.getACallee*() = calledMethod and
      // Exclude initialization methods from analysis
      not calledMethod.getName() = "__init__" and
      // Verify mutation occurs within the called method's scope
      mutationOperation.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify classes and specific locations where descriptor mutations occur
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorClass, mutationOperation)
// Report mutation location with contextual warning and class information
select mutationOperation,
  "Mutation of descriptor $@ object may cause action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()