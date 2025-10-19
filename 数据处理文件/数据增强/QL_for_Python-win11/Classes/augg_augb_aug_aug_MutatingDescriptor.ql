/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects mutations within descriptor protocol methods that can cause shared state issues.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// Identifies descriptor classes where mutation operations occur within protocol method call chains
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutatingOp) {
  // Verify the class implements descriptor protocol
  descriptorCls.isDescriptorType() and
  // Find descriptor protocol methods (__get__/__set__/__delete__)
  exists(string protocolMethodName, PyFunctionObject descriptorMethod |
    descriptorCls.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // Locate methods invoked by descriptor protocol methods
    exists(PyFunctionObject calledMethod |
      // Called method belongs to the same descriptor class
      descriptorCls.lookupAttribute(_) = calledMethod and
      // Trace call chain from protocol method to called method
      descriptorMethod.getACallee*() = calledMethod and
      // Exclude initialization methods from analysis
      not calledMethod.getName() = "__init__" and
      // Mutation occurs within the called method's scope
      mutatingOp.getScope() = calledMethod.getFunction()
    )
  )
}

// Identify descriptor classes and their mutation operations
from ClassObject descriptorCls, SelfAttributeStore mutatingOp
where has_descriptor_mutation(descriptorCls, mutatingOp)
// Output mutation location with warning message and class details
select mutatingOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()