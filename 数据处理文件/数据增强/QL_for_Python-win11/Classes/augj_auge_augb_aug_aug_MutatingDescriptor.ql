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
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore stateMutation) {
  // Verify the class implements the descriptor protocol
  descriptorClass.isDescriptorType() and
  
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    // Check if the class has the protocol method
    descriptorClass.lookupAttribute(methodName) = protocolMethod and
    // Verify it's one of the descriptor protocol methods
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    
    // Locate methods invoked by descriptor protocol methods
    exists(PyFunctionObject mutatingMethod |
      // The called method must belong to the same descriptor class
      descriptorClass.lookupAttribute(_) = mutatingMethod and
      
      // Trace the call chain from protocol method to mutating method
      protocolMethod.getACallee*() = mutatingMethod and
      
      // Exclude initialization methods from analysis
      not mutatingMethod.getName() = "__init__" and
      
      // Mutation occurs within the mutating method's scope
      stateMutation.getScope() = mutatingMethod.getFunction()
    )
  )
}

// Identify descriptor classes and their mutation operations
from ClassObject descriptorClass, SelfAttributeStore stateMutation
where has_descriptor_mutation(descriptorClass, stateMutation)
// Output mutation location with warning message and class details
select stateMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()