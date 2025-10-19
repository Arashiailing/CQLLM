/**
 * @name Descriptor mutation in protocol methods (__get__, __set__, __delete__)
 * @description Detects mutation operations within descriptor protocol methods that may cause side effects across instances
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes containing mutation operations in their protocol methods
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutationOperation) {
  // Validate class implements descriptor protocol
  descriptorCls.isDescriptorType() and
  // Find protocol methods (__get__/__set__/__delete__)
  exists(string protocolMethodName, PyFunctionObject protocolMethod |
    descriptorCls.lookupAttribute(protocolMethodName) = protocolMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Locate methods invoked by protocol methods
    exists(PyFunctionObject calledMethod |
      // Called method belongs to same class
      descriptorCls.lookupAttribute(_) = calledMethod and
      // Trace call chain from protocol method to invoked method
      protocolMethod.getACallee*() = calledMethod and
      // Exclude initialization methods
      not calledMethod.getName() = "__init__" and
      // Mutation occurs within invoked method's scope
      mutationOperation.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify classes and operations where descriptor mutation occurs
from ClassObject descriptorCls, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorCls, mutationOperation)
// Output mutation location, warning message, and related class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()