/**
 * @name Descriptor mutation in protocol methods (__get__, __set__, __delete__)
 * @description Since descriptor objects are shared across multiple instances, any mutation within their protocol methods can result in unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies classes implementing the descriptor protocol that perform mutation operations within their protocol methods
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutationOp) {
  // Verify the class implements descriptor protocol
  descClass.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(string methodName, PyFunctionObject descMethod |
    descClass.lookupAttribute(methodName) = descMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // Locate methods called by descriptor protocol methods
    exists(PyFunctionObject calleeMethod |
      // Called method belongs to the same class
      descClass.lookupAttribute(_) = calleeMethod and
      // Trace call chain from descriptor method to called method
      descMethod.getACallee*() = calleeMethod and
      // Exclude initialization methods
      not calleeMethod.getName() = "__init__" and
      // Mutation occurs within the called method's scope
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