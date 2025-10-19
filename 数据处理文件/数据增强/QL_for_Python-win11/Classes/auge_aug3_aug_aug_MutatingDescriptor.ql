/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects are shared across many instances. Mutating them can cause side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes containing mutation operations in descriptor methods or their callees
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutationOp) {
  // Ensure class implements descriptor protocol
  descClass.isDescriptorType() and
  // Find descriptor protocol methods
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    descClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Trace mutation operations through call chain
    exists(PyFunctionObject invokedMethod |
      // Invoked method belongs to same descriptor class
      descClass.lookupAttribute(_) = invokedMethod and
      // Establish call relationship from descriptor method
      descriptorMethod.getACallee*() = invokedMethod and
      // Exclude initialization methods
      not invokedMethod.getName() = "__init__" and
      // Mutation occurs within invoked method's scope
      mutationOp.getScope() = invokedMethod.getFunction()
    )
  )
}

// Identify problematic descriptor classes and mutation locations
from ClassObject descClass, SelfAttributeStore mutationOp
where has_descriptor_mutation(descClass, mutationOp)
// Output mutation location with contextual warning
select mutationOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()