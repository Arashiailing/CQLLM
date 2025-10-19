/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects mutations within descriptor protocol methods that can cause shared state issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes containing mutation operations in protocol methods
predicate has_descriptor_mutation(ClassObject targetDescriptorClass, SelfAttributeStore stateMutation) {
  // Verify the class implements the descriptor protocol
  targetDescriptorClass.isDescriptorType() and
  
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    // Check if the class has the protocol method
    targetDescriptorClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    // Verify it's one of the descriptor protocol methods
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    
    // Locate methods invoked by descriptor protocol methods
    exists(PyFunctionObject calledMethod |
      // The called method must belong to the same descriptor class
      targetDescriptorClass.lookupAttribute(_) = calledMethod and
      
      // Trace the call chain from protocol method to called method
      descriptorMethod.getACallee*() = calledMethod and
      
      // Exclude initialization methods from analysis
      not calledMethod.getName() = "__init__" and
      
      // Mutation occurs within the called method's scope
      stateMutation.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify descriptor classes and their mutation operations
from ClassObject targetDescriptorClass, SelfAttributeStore stateMutation
where has_descriptor_mutation(targetDescriptorClass, stateMutation)
// Output mutation location with warning message and class details
select stateMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  targetDescriptorClass, targetDescriptorClass.getName()