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
predicate isUnhashableObject(ControlFlowNode targetNode, ClassValue unhashableClass, ControlFlowNode sourceNode) {
  exists(Value unhashableValue | 
    targetNode.pointsTo(unhashableValue, sourceNode) and 
    unhashableValue.getClass() = unhashableClass |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
  )
}

// Main query: Detect unhandled unhashable operations
from ControlFlowNode operationNode, ClassValue unhashableClass, ControlFlowNode originNode
where
  // Filter out TypeError handling blocks
  not exists(Try tryBlock |
    tryBlock.getBody().contains(operationNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  ) and
  (
    // Case 1: Explicit hash() function calls
    exists(CallNode hashCall, GlobalVariable hashVar |
      hashCall.getArg(0) = operationNode and 
      hashCall.getFunction().(NameNode).uses(hashVar) and 
      hashVar.getId() = "hash"
    ) and isUnhashableObject(operationNode, unhashableClass, originNode)
    or
    // Case 2: Unhashable indices in subscript operations
    isUnhashableObject(operationNode, unhashableClass, originNode) and
    exists(SubscriptNode subscriptNode | 
      subscriptNode.getIndex() = operationNode |
      exists(Value containerValue |
        subscriptNode.getObject().pointsTo(containerValue) and
        // Exclude objects with custom __getitem__ (including numpy arrays)
        not (
          containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
          or
          exists(ModuleValue numpyModule | 
            (numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core") and
            containerValue.getClass().getASuperType() = numpyModule.attr("ndarray")
          )
        )
      )
    )
  )
select operationNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()