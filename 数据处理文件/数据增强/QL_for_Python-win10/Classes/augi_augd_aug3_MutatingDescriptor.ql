/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects mutations to descriptor objects within their accessor methods. 
 *              Such mutations can cause unexpected side effects and race conditions 
 *              since descriptors are shared across multiple instances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes with mutations in accessor methods
predicate hasDescriptorMutation(ClassObject descClass, SelfAttributeStore mutationAssignment) {
  // Verify the class implements the descriptor protocol
  descClass.isDescriptorType() and
  // Find accessor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject accessorMethod |
    exists(string methodName |
      methodName in ["__get__", "__set__", "__delete__"] and
      descClass.lookupAttribute(methodName) = accessorMethod
    ) and
    // Locate mutating methods called by accessors
    exists(PyFunctionObject mutatorMethod |
      // Ensure method belongs to descriptor class
      descClass.lookupAttribute(_) = mutatorMethod and
      // Verify method is invoked by accessor
      accessorMethod.getACallee*() = mutatorMethod and
      // Exclude initialization methods
      not mutatorMethod.getName() = "__init__" and
      // Confirm mutation occurs within method scope
      mutationAssignment.getScope() = mutatorMethod.getFunction()
    )
  )
}

// Query for descriptor mutations
from ClassObject descClass, SelfAttributeStore mutationAssignment
where hasDescriptorMutation(descClass, mutationAssignment)
select mutationAssignment,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()