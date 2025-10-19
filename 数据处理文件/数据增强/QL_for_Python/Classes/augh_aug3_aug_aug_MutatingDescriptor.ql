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

// Identifies classes implementing descriptor protocol that perform mutations
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOperation) {
  // Verify class implements descriptor protocol
  descriptorClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string descriptorMethodName |
    descriptorClass.lookupAttribute(descriptorMethodName) = descriptorMethod and
    (descriptorMethodName = "__get__" or descriptorMethodName = "__set__" or descriptorMethodName = "__delete__") and
    // Locate methods called by descriptor protocol methods
    exists(PyFunctionObject calledMethod |
      // Called method belongs to the same class
      descriptorClass.lookupAttribute(_) = calledMethod and
      // Trace call chain from descriptor method to called method
      descriptorMethod.getACallee*() = calledMethod and
      // Exclude initialization methods
      not calledMethod.getName() = "__init__" and
      // Mutation occurs within the called method's scope
      mutationOperation.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify classes and operations where descriptor mutation occurs
from ClassObject descriptorClass, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorClass, mutationOperation)
// Output mutation location, warning message, and related class details
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()