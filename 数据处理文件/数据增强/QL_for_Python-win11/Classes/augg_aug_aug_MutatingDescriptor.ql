/**
 * @name Mutation of descriptor in `__get__` or `__set__` method
 * @description Descriptor objects are often shared across instances. Mutating them can cause 
 *              unexpected side effects or race conditions due to shared state.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Detects classes implementing descriptor protocol that perform state mutations
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutationOp) {
  // Verify class implements descriptor protocol
  descClass.isDescriptorType() and
  // Identify descriptor methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descMethod, string methodName |
    descClass.lookupAttribute(methodName) = descMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Find methods invoked by descriptor protocol
    exists(PyFunctionObject invokedMethod |
      // Invoked method belongs to same class
      descClass.lookupAttribute(_) = invokedMethod and
      // Trace call chain from descriptor to invoked method
      descMethod.getACallee*() = invokedMethod and
      // Exclude initialization methods
      not invokedMethod.getName() = "__init__" and
      // Mutation occurs within invoked method's scope
      mutationOp.getScope() = invokedMethod.getFunction()
    )
  )
}

// Identify classes and locations where descriptor mutations occur
from ClassObject descClass, SelfAttributeStore mutationOp
where has_descriptor_mutation(descClass, mutationOp)
// Output mutation location, warning message, and class details
select mutationOp,
  "Mutation of descriptor $@ object may cause action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()