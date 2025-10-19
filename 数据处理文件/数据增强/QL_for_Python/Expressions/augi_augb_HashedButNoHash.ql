/**
 * @name Unhashable object hashed
 * @description Hashing an object which is not hashable will result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/hash-unhashable-value
 */

import python

/**
 * This assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so we don't need to treat them specially.
 * For numpy arrays, the index may be a list, which are not hashable and needs to be treated specially.
 */

// Identifies numpy array types through module inheritance
predicate is_numpy_array(ClassValue numpyArray) {
  exists(ModuleValue np | np.getName() = "numpy" or np.getName() = "numpy.core" |
    numpyArray.getASuperType() = np.attr("ndarray")
  )
}

// Checks if a value has custom __getitem__ implementation
predicate has_custom_getitem_method(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array(value.getClass())
}

// Detects explicit hashing operations via hash() function
predicate is_explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = cfNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Determines if an object lacks hashability
predicate is_unhashable(ControlFlowNode cfNode, ClassValue unhashableClass, ControlFlowNode originCfNode) {
  exists(Value pointedValue | 
    cfNode.pointsTo(pointedValue, originCfNode) and 
    pointedValue.getClass() = unhashableClass
  |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Identifies subscript operations using unhashable objects
predicate is_unhashable_subscript(ControlFlowNode indexCfNode, ClassValue unhashableClass, ControlFlowNode originCfNode) {
  is_unhashable(indexCfNode, unhashableClass, originCfNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexCfNode |
    exists(Value container |
      subscriptNode.getObject().pointsTo(container) and
      not has_custom_getitem_method(container)
    )
  )
}

/**
 * Holds if `cfNode` is inside a `try` that catches `TypeError`. For example:
 *
 *    try:
 *       ... cfNode ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives where unhashable operations
 * are intentionally handled through exception catching.
 */
// Checks if a node is within a TypeError-handling try block
predicate is_typeerror_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Finds unhandled hashing/subscript operations on unhashable objects
from ControlFlowNode node, ClassValue cls, ControlFlowNode originNode
where
  not is_typeerror_caught(node) and
  (
    is_explicitly_hashed(node) and is_unhashable(node, cls, originNode)
    or
    is_unhashable_subscript(node, cls, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", cls, cls.getQualifiedName()