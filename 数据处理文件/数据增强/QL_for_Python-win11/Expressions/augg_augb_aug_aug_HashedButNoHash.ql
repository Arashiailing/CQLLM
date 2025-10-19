/**
 * @name Unhashable object hashed
 * @description Detects usage of unhashable objects in hashing contexts which causes runtime TypeError.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/hash-unhashable-value
 */

import python

/*
 * Identifies cases where unhashable objects are used in hashing operations.
 * Assumes subscript indexing with non-sequence/non-numpy indices involves hashing.
 * Sequences require integer indices (hashable) while numpy arrays may use list indices (unhashable).
 */

// Identifies numpy array types through inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has custom __getitem__ implementation or is a numpy array
predicate has_custom_getitem(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(containerValue.getClass())
}

// Checks if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode cfNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  exists(Value value | 
    cfNode.pointsTo(value, originNode) and 
    value.getClass() = unhashableCls |
    (
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

// Identifies nodes explicitly hashed using the hash() function
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashFuncCall, GlobalVariable hashGlobalVar |
    hashFuncCall.getArg(0) = cfNode and 
    hashFuncCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Detects subscript operations with unhashable index objects
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableCls, originNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

/**
 * Holds if `cfNode` is inside a `try` block that catches `TypeError`. For example:
 *
 *    try:
 *       ... cfNode ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives where hashing an unhashable object
 * is intentionally handled by catching the resulting TypeError.
 */
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query finding unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode issueNode, ClassValue issueClass, ControlFlowNode originNode
where
  not typeerror_is_caught(issueNode) and
  (
    explicitly_hashed(issueNode) and is_unhashable(issueNode, issueClass, originNode)
    or
    unhashable_subscript(issueNode, issueClass, originNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", issueClass, issueClass.getQualifiedName()