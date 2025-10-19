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
predicate hasCustomGetitem(Value value) {
  // Check for custom __getitem__ method
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Handle numpy array special case
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    value.getClass().getASuperType() = numpyModule.attr("ndarray")
  )
}

// Detects explicit hash() calls on control flow nodes
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Checks if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableValue(ControlFlowNode node, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value value | 
    node.pointsTo(value, originNode) and 
    value.getClass() = unhashableType |
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
predicate hasUnhashableSubscript(ControlFlowNode indexExpr, ClassValue unhashableType, ControlFlowNode originNode) {
  isUnhashableValue(indexExpr, unhashableType, originNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexExpr |
    exists(Value container |
      subscript.getObject().pointsTo(container) and
      not hasCustomGetitem(container)
    )
  )
}

/**
 * Determines if a node is inside a try block that catches TypeError.
 * Used to eliminate false positives where TypeError is intentionally handled.
 */
predicate typeErrorIsHandled(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable operations
from ControlFlowNode node, ClassValue unhashableType, ControlFlowNode originNode
where
  not typeErrorIsHandled(node) and
  (
    // Case 1: Explicit hash() call on unhashable value
    isExplicitlyHashed(node) and isUnhashableValue(node, unhashableType, originNode)
    or
    // Case 2: Unhashable value used as subscript index
    hasUnhashableSubscript(node, unhashableType, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()