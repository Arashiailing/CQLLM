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
predicate hasCustomGetitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Inline numpy array type check
  exists(ModuleValue npModule | npModule.getName() = "numpy" or npModule.getName() = "numpy.core" |
    targetValue.getClass().getASuperType() = npModule.attr("ndarray")
  )
}

// Detects explicit hash() calls on control flow nodes
predicate isExplicitlyHashed(ControlFlowNode flowNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = flowNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Checks if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableValue(ControlFlowNode flowNode, ClassValue unhashableType, ControlFlowNode originFlowNode) {
  exists(Value targetValue | flowNode.pointsTo(targetValue, originFlowNode) and targetValue.getClass() = unhashableType |
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies unhashable indices in subscript operations without custom __getitem__
predicate hasUnhashableSubscript(ControlFlowNode indexNode, ClassValue unhashableType, ControlFlowNode originFlowNode) {
  isUnhashableValue(indexNode, unhashableType, originFlowNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
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
predicate typeErrorIsHandled(ControlFlowNode flowNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(flowNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable operations
from ControlFlowNode flowNode, ClassValue unhashableType, ControlFlowNode originFlowNode
where
  not typeErrorIsHandled(flowNode) and
  (
    isExplicitlyHashed(flowNode) and isUnhashableValue(flowNode, unhashableType, originFlowNode)
    or
    hasUnhashableSubscript(flowNode, unhashableType, originFlowNode)
  )
select flowNode.getNode(), "This $@ of $@ is unhashable.", originFlowNode, "instance", unhashableType, unhashableType.getQualifiedName()