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

/*
 * This analysis identifies unhashable objects being used in contexts requiring hashability.
 * We consider two primary scenarios:
 * 1. Explicit hashing via built-in hash() function
 * 2. Subscript operations where the index must be hashable
 * 
 * Special handling is applied for:
 * - Sequence types (indices must be integers, which are hashable)
 * - NumPy arrays (may accept non-hashable list indices)
 */

// Identifies classes that inherit from numpy.ndarray
predicate isNumpyArrayType(ClassValue numpyClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value has custom indexing behavior
predicate hasCustomIndexingBehavior(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(targetValue.getClass())
}

// Detects explicit calls to the built-in hash() function
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashRef |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashRef) and 
    hashRef.getId() = "hash"
  )
}

// Identifies subscript operations with unhashable indices on standard containers
predicate isUnhashableSubscript(ControlFlowNode indexNode, ClassValue unhashableType, ControlFlowNode originNode) {
  isUnhashableObject(indexNode, unhashableType, originNode) and
  exists(SubscriptNode subscriptAccess | subscriptAccess.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptAccess.getObject().pointsTo(containerValue) and
      not hasCustomIndexingBehavior(containerValue)
    )
  )
}

// Determines if a control flow node points to an unhashable object
predicate isUnhashableObject(ControlFlowNode node, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value targetValue | 
    node.pointsTo(targetValue, originNode) and 
    targetValue.getClass() = unhashableType
  |
    // Case 1: Class lacks __hash__ method (and isn't a failed inference)
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    // Case 2: Class explicitly sets __hash__ to None
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Identifies nodes protected by TypeError handling. For example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * This predicate reduces false positives by excluding cases where
 * potential TypeErrors are explicitly handled by the application.
 */
predicate isTypeErrorHandled(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query identifying unhandled unhashable object usage
from ControlFlowNode node, ClassValue unhashableType, ControlFlowNode originNode
where
  not isTypeErrorHandled(node) and
  (
    // Scenario 1: Direct hashing of unhashable object
    isExplicitlyHashed(node) and isUnhashableObject(node, unhashableType, originNode)
    or
    // Scenario 2: Unhashable index in standard container access
    isUnhashableSubscript(node, unhashableType, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()