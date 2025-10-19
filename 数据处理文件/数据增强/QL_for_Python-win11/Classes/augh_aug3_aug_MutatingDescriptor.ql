/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects are shared across instances. Mutating them may cause unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes containing mutation operations
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Locate descriptor methods and their call chains
  exists(PyFunctionObject descriptorMethod, string protocolMethodName, PyFunctionObject calledMemberFunction |
    // Identify descriptor protocol methods
    descriptorClass.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Find class member functions called by descriptor methods
    descriptorClass.lookupAttribute(_) = calledMemberFunction and
    // Exclude initialization methods and verify call relationship
    not calledMemberFunction.getName() = "__init__" and
    descriptorMethod.getACallee*() = calledMemberFunction and
    // Confirm mutation occurs within called member function scope
    mutationOperation.getScope() = calledMemberFunction.getFunction()
  )
}

// Locate classes with descriptor mutations and their operations
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorClass, mutationOperation)
// Output mutation location, warning message, related class and its name
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()