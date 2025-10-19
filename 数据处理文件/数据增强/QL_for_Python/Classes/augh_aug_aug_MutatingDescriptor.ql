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

// Detects classes implementing descriptor protocol that perform mutation operations
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutationOp) {
  // Verify class implements descriptor protocol
  descClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(PyFunctionObject descMethod, string methodName |
    descClass.lookupAttribute(methodName) = descMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Trace method calls from descriptor protocol methods
    exists(PyFunctionObject calleeMethod |
      // Called method belongs to same descriptor class
      descClass.lookupAttribute(_) = calleeMethod and
      // Follow call chain from descriptor method to callee
      descMethod.getACallee*() = calleeMethod and
      // Exclude initialization methods
      not calleeMethod.getName() = "__init__" and
      // Mutation occurs within callee method's scope
      mutationOp.getScope() = calleeMethod.getFunction()
    )
  )
}

// Identify classes and operations where descriptor mutation occurs
from ClassObject descClass, SelfAttributeStore mutationOp
where has_descriptor_mutation(descClass, mutationOp)
// Output mutation location, warning message, and related class details
select mutationOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()