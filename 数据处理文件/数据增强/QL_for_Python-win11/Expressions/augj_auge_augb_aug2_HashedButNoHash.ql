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
predicate hasCustomGetitemMethod(Value objectToCheck) {
  objectToCheck.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Special handling for numpy arrays
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    objectToCheck.getClass().getASuperType() = numpyModule.attr("ndarray")
  )
}

// Detects explicit hash() function calls on control flow nodes
predicate isExplicitHashCall(ControlFlowNode callNode) {
  exists(CallNode hashFunctionCall, GlobalVariable hashGlobal |
    hashFunctionCall.getArg(0) = callNode and 
    hashFunctionCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Determines if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableObject(ControlFlowNode valueNode, ClassValue unhashableType, ControlFlowNode origin) {
  exists(Value targetObject | 
    valueNode.pointsTo(targetObject, origin) and 
    targetObject.getClass() = unhashableType |
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Identifies unhashable indices in subscript operations without custom __getitem__
predicate hasUnhashableSubscriptIndex(ControlFlowNode indexNode, ClassValue unhashableType, ControlFlowNode origin) {
  isUnhashableObject(indexNode, unhashableType, origin) and
  exists(SubscriptNode subscriptOperation | 
    subscriptOperation.getIndex() = indexNode |
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
predicate isTypeErrorHandled(ControlFlowNode nodeToCheck) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(nodeToCheck.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Detect unhandled unhashable operations
from ControlFlowNode operationNode, ClassValue unhashableType, ControlFlowNode origin
where
  not isTypeErrorHandled(operationNode) and
  (
    // Case 1: Explicit hash() call on unhashable object
    isExplicitHashCall(operationNode) and 
    isUnhashableObject(operationNode, unhashableType, origin)
    or
    // Case 2: Unhashable object used as subscript index
    hasUnhashableSubscriptIndex(operationNode, unhashableType, origin)
  )
select operationNode.getNode(), "This $@ of $@ is unhashable.", origin, "instance", unhashableType, unhashableType.getQualifiedName()