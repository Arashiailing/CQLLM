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
 * Core assumption: Any indexing operation where the index value is not a sequence or numpy array involves hashing.
 * - Sequences require integer indices (which are hashable), requiring no special handling.
 * - Numpy arrays may use list indices (which are unhashable), requiring special detection.
 */

// Determines if a class inherits from numpy.ndarray or numpy.core.ndarray
predicate isNumpyArrayType(ClassValue numpyType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value has a custom __getitem__ implementation (including numpy arrays)
predicate hasCustomGetitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(targetValue.getClass())
}

// Identifies nodes used as arguments to the built-in hash() function
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// Detects unhashable objects used as subscripts in non-custom containers
predicate isUnhashableSubscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode originPoint) {
  isUnhashable(indexNode, unhashableCls, originPoint) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptOp.getObject().pointsTo(containerValue) and
      not hasCustomGetitem(containerValue)
    )
  )
}

// Determines if a node points to an unhashable class (missing __hash__ or __hash__=None)
predicate isUnhashable(ControlFlowNode node, ClassValue unhashableCls, ControlFlowNode originPoint) {
  exists(Value pointedValue | 
    node.pointsTo(pointedValue, originPoint) and 
    pointedValue.getClass() = unhashableCls |
    (
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `node` is inside a `try` block that catches `TypeError`. For example:
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * This predicate eliminates false positives by detecting proper error handling.
 * When hash() is called on an unhashable object, a `TypeError` is thrown.
 * This is not a bug if the code catches and handles the exception.
 */
// Checks if a node is inside a try block catching TypeError
predicate isTypeErrorCaught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Detects unhandled unhashable operations
from ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode originNode
where
  not isTypeErrorCaught(targetNode) and
  (
    isExplicitlyHashed(targetNode) and isUnhashable(targetNode, unhashableType, originNode)
    or
    isUnhashableSubscript(targetNode, unhashableType, originNode)
  )
select targetNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()