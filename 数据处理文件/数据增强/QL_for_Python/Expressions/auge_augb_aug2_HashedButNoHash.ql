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
 * Core detection logic: Objects are unhashable if they lack a valid __hash__ method.
 * Special handling:
 * - Sequences and numpy arrays with custom __getitem__ are excluded
 * - Try-except blocks catching TypeError are filtered to avoid false positives
 */

// Identifies objects with custom __getitem__ implementation (including numpy arrays)
predicate hasCustomGetitemMethod(Value targetObject) {
  targetObject.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Special handling for numpy arrays
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    targetObject.getClass().getASuperType() = numpyModule.attr("ndarray")
  )
}

// Detects explicit hash() function calls on control flow nodes
predicate isExplicitHashCall(ControlFlowNode node) {
  exists(CallNode hashFunctionCall, GlobalVariable hashGlobal |
    hashFunctionCall.getArg(0) = node and 
    hashFunctionCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Determines if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableObject(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value targetObject | 
    node.pointsTo(targetObject, originNode) and 
    targetObject.getClass() = unhashableClass |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Identifies unhashable indices in subscript operations without custom __getitem__
predicate hasUnhashableSubscriptIndex(ControlFlowNode subscriptIndex, ClassValue unhashableClass, ControlFlowNode originNode) {
  isUnhashableObject(subscriptIndex, unhashableClass, originNode) and
  exists(SubscriptNode subscriptOperation | 
    subscriptOperation.getIndex() = subscriptIndex |
    exists(Value containerObject |
      subscriptOperation.getObject().pointsTo(containerObject) and
      not hasCustomGetitemMethod(containerObject)
    )
  )
}

/**
 * Checks if a node is inside a try block that catches TypeError.
 * Used to eliminate false positives where TypeError is intentionally handled.
 */
predicate isTypeErrorHandled(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Detect unhandled unhashable operations
from ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode
where
  not isTypeErrorHandled(node) and
  (
    isExplicitHashCall(node) and isUnhashableObject(node, unhashableClass, originNode)
    or
    hasUnhashableSubscriptIndex(node, unhashableClass, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()