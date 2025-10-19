/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description This query detects classes implementing the descriptor protocol that mutate their state within descriptor methods.
 *              Such mutations can cause action-at-a-distance effects or race conditions since descriptors are shared across instances.
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
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutationOp) {
  // Validate class implements descriptor protocol
  descriptorCls.isDescriptorType() and
  
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string protocolMethodName |
    descriptorCls.lookupAttribute(protocolMethodName) = protocolMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    
    // Locate methods invoked by protocol methods
    exists(PyFunctionObject invokedMethod |
      // Ensure invoked method belongs to the same descriptor class
      descriptorCls.lookupAttribute(_) = invokedMethod and
      // Exclude initialization methods from analysis
      not invokedMethod.getName() = "__init__" and
      // Trace call chain from protocol method to invoked method
      protocolMethod.getACallee*() = invokedMethod and
      // Identify mutation operations within the invoked method's scope
      mutationOp.getScope() = invokedMethod.getFunction()
    )
  )
}

// Find classes and mutation operations violating descriptor immutability
from ClassObject descriptorCls, SelfAttributeStore mutationOp
where has_descriptor_mutation(descriptorCls, mutationOp)
// Report mutation location with contextual warning and class details
select mutationOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()