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
predicate hasCustomGetitem(Value val) {
  // Check for custom __getitem__ method
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Handle numpy arrays specifically
  exists(ModuleValue npModule | 
    npModule.getName() = "numpy" or npModule.getName() = "numpy.core" |
    val.getClass().getASuperType() = npModule.attr("ndarray")
  )
}

// Detects explicit hash() calls on control flow nodes
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode call, GlobalVariable globalVar |
    call.getArg(0) = node and 
    call.getFunction().(NameNode).uses(globalVar) and 
    globalVar.getId() = "hash"
  )
}

// Checks if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableValue(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  exists(Value targetValue | 
    node.pointsTo(targetValue, origin) and 
    targetValue.getClass() = cls |
    // Either missing __hash__ method or explicitly set to None
    (not cls.hasAttribute("__hash__") and 
     not cls.failedInference(_) and 
     cls.isNewStyle())
    or
    cls.lookup("__hash__") = Value::named("None")
  )
}

// Identifies unhashable indices in subscript operations without custom __getitem__
predicate hasUnhashableSubscript(ControlFlowNode index, ClassValue cls, ControlFlowNode origin) {
  isUnhashableValue(index, cls, origin) and
  exists(SubscriptNode subscriptOp, Value containerValue |
    subscriptOp.getIndex() = index and
    subscriptOp.getObject().pointsTo(containerValue) and
    not hasCustomGetitem(containerValue)
  )
}

/**
 * Determines if a node is inside a try block that catches TypeError.
 * Used to eliminate false positives where TypeError is intentionally handled.
 */
predicate typeErrorIsHandled(ControlFlowNode node) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable operations
from ControlFlowNode node, ClassValue cls, ControlFlowNode origin
where
  not typeErrorIsHandled(node) and
  (
    isExplicitlyHashed(node) and isUnhashableValue(node, cls, origin)
    or
    hasUnhashableSubscript(node, cls, origin)
  )
select node.getNode(), "This $@ of $@ is unhashable.", origin, "instance", cls, cls.getQualifiedName()