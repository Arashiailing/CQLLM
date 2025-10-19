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

// Determines if a value belongs to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashableObject(ControlFlowNode valueNode, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value unhashableValue | 
    valueNode.pointsTo(unhashableValue, originNode) and 
    unhashableValue.getClass() = unhashableType |
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Main query: Detect unhandled unhashable operations
from ControlFlowNode operationNode, ClassValue unhashableType, ControlFlowNode originNode
where
  // Filter out TypeError handling blocks
  not exists(Try tryBlock |
    tryBlock.getBody().contains(operationNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  ) and
  (
    // Case 1: Explicit hash() function calls
    exists(CallNode hashFunctionCall, GlobalVariable hashGlobalVar |
      hashFunctionCall.getArg(0) = operationNode and 
      hashFunctionCall.getFunction().(NameNode).uses(hashGlobalVar) and 
      hashGlobalVar.getId() = "hash"
    ) and isUnhashableObject(operationNode, unhashableType, originNode)
    or
    // Case 2: Unhashable indices in subscript operations
    isUnhashableObject(operationNode, unhashableType, originNode) and
    exists(SubscriptNode subscriptOperation | 
      subscriptOperation.getIndex() = operationNode |
      exists(Value containerType |
        subscriptOperation.getObject().pointsTo(containerType) and
        // Exclude objects with custom __getitem__ (including numpy arrays)
        not (
          containerType.getClass().lookup("__getitem__") instanceof PythonFunctionValue
          or
          exists(ModuleValue numpyModule | 
            (numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core") and
            containerType.getClass().getASuperType() = numpyModule.attr("ndarray")
          )
        )
      )
    )
  )
select operationNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()