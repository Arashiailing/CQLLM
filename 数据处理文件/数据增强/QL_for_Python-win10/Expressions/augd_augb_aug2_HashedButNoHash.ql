/**
 * @name Unhashable object hashed
 * @description Detects unhashable objects being hashed or used as dictionary keys,
 *              which will raise TypeError at runtime.
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
 * Core logic: Objects are considered hashable if they have a valid __hash__ method.
 * Special cases:
 * - Sequences and numpy arrays are handled separately as they may allow non-hashable indices
 * - Try-except blocks catching TypeError are excluded to avoid false positives
 */

// Identifies values with custom __getitem__ implementation (including numpy arrays)
predicate hasCustomGetitem(Value objValue) {
  objValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Inline numpy array type check
  exists(ModuleValue npModule | npModule.getName() = "numpy" or npModule.getName() = "numpy.core" |
    objValue.getClass().getASuperType() = npModule.attr("ndarray")
  )
}

// Detects explicit hash() calls on control flow nodes
predicate isExplicitlyHashed(ControlFlowNode hashedNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = hashedNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Checks if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableValue(ControlFlowNode unhashableNode, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value targetValue | unhashableNode.pointsTo(targetValue, originNode) and targetValue.getClass() = unhashableType |
    // Case 1: Class lacks __hash__ method
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    // Case 2: Class explicitly sets __hash__ to None
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies unhashable indices in subscript operations without custom __getitem__
predicate hasUnhashableSubscript(ControlFlowNode subscriptIndexNode, ClassValue unhashableType, ControlFlowNode originNode) {
  isUnhashableValue(subscriptIndexNode, unhashableType, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = subscriptIndexNode |
    exists(Value containerValue |
      subscriptOp.getObject().pointsTo(containerValue) and
      not hasCustomGetitem(containerValue)
    )
  )
}

/**
 * Determines if a node is inside a try block that catches TypeError.
 * Used to eliminate false positives where TypeError is intentionally handled.
 */
predicate typeErrorIsHandled(ControlFlowNode nodeInTryBlock) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(nodeInTryBlock.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable operations
from ControlFlowNode flowNode, ClassValue unhashableType, ControlFlowNode originFlowNode
where
  not typeErrorIsHandled(flowNode) and
  (
    // Case 1: Explicit hashing of unhashable value
    (isExplicitlyHashed(flowNode) and isUnhashableValue(flowNode, unhashableType, originFlowNode))
    or
    // Case 2: Unhashable value used as subscript index
    hasUnhashableSubscript(flowNode, unhashableType, originFlowNode)
  )
select flowNode.getNode(), "This $@ of $@ is unhashable.", originFlowNode, "instance", unhashableType, unhashableType.getQualifiedName()