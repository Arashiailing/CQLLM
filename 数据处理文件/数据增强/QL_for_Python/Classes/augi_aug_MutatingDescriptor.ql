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

// Identify descriptor classes containing mutation operations within descriptor protocol methods
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutationOperation) {
  // Verify the class implements the descriptor protocol
  descriptorCls.isDescriptorType() and
  // Locate descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descMethod, string protocolMethodName |
    descMethod = descriptorCls.lookupAttribute(protocolMethodName) and
    protocolMethodName in ["__get__", "__set__", "__delete__"] and
    // Find functions invoked by descriptor methods
    exists(PyFunctionObject invokedFunc |
      // Ensure invoked function belongs to the descriptor class
      invokedFunc = descriptorCls.lookupAttribute(_) and
      // Trace call graph from descriptor method to invoked function
      invokedFunc = descMethod.getACallee*() and
      // Exclude initialization methods from analysis
      invokedFunc.getName() != "__init__" and
      // Confirm mutation occurs within invoked function's scope
      mutationOperation.getScope() = invokedFunc.getFunction()
    )
  )
}

// Detect classes with descriptor mutations and associated operations
from ClassObject descriptorCls, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorCls, mutationOperation)
// Report mutation location, warning message, and affected class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()