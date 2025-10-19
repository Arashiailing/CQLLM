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

// Detects descriptor mutations within accessor methods by identifying:
// 1. Classes implementing the descriptor protocol
// 2. Accessor methods (__get__/__set__/__delete__)
// 3. Mutating functions called by accessors
// 4. Attribute stores within mutating functions' scope
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attrStore) {
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find accessor methods and their associated mutating functions
  exists(PyFunctionObject accessor, string methodName, PyFunctionObject mutator |
    // Identify descriptor protocol accessors
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    descriptorClass.lookupAttribute(methodName) = accessor and
    // Locate mutating functions belonging to the descriptor class
    descriptorClass.lookupAttribute(_) = mutator and
    // Ensure mutator is called by accessor (directly or transitively)
    accessor.getACallee*() = mutator and
    // Exclude initialization methods from mutation detection
    not mutator.getName() = "__init__" and
    // Confirm attribute mutation occurs within mutator's scope
    attrStore.getScope() = mutator.getFunction()
  )
}

// Query for descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attrStore
where mutates_descriptor(descriptorClass, attrStore)
select attrStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()