/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description This query identifies mutations of descriptor objects within their accessor methods (__get__, __set__, or __delete__). 
 *              Descriptor objects are shared across multiple instances, and mutating them can lead to unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Detects descriptor mutations within accessor methods
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attrStore) {
  // Validate the class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Identify accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject accessor |
    exists(string methodName | methodName in ["__get__", "__set__", "__delete__"] |
      descriptorClass.lookupAttribute(methodName) = accessor
    ) and
    // Locate mutating methods called by accessors
    exists(PyFunctionObject mutatingMethod |
      // Ensure mutatingMethod belongs to descriptor class
      mutatingMethod = descriptorClass.lookupAttribute(_) and
      // Verify mutatingMethod is invoked by accessor
      accessor.getACallee*() = mutatingMethod and
      // Exclude initialization methods
      mutatingMethod.getName() != "__init__" and
      // Confirm mutation occurs within mutatingMethod's scope
      attrStore.getScope() = mutatingMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descriptorClass, SelfAttributeStore attrStore
where mutates_descriptor(descriptorClass, attrStore)
select attrStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()