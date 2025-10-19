/**
 * @name Hashing of non-hashable object
 * @description Attempting to hash an object that is not hashable leads to a TypeError during execution.
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
 * This analysis assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int (which are hashable), so they don't require special handling.
 * For numpy arrays, the index may be a list (which are not hashable) and needs special treatment.
 */

// Identifies numpy array types through inheritance from numpy.ndarray
predicate numpy_array_type(ClassValue arrType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value implements custom __getitem__ behavior
predicate has_custom_getitem(Value obj) {
  obj.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(obj.getClass())
}

// Detects explicit hash() function calls
predicate explicitly_hashed(ControlFlowNode nodeToHash) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = nodeToHash and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Determines if an object is unhashable by examining its __hash__ attribute
predicate is_unhashable(ControlFlowNode nodeToCheck, ClassValue unhashableCls, ControlFlowNode originNode) {
  exists(Value val | 
    nodeToCheck.pointsTo(val, originNode) and 
    val.getClass() = unhashableCls |
    (
      not unhashableCls.hasAttribute("__hash__") and 
      not unhashableCls.failedInference(_) and 
      unhashableCls.isNewStyle()
    )
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
  )
}

// Identifies subscript operations using unhashable indices
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableCls, originNode) and
  exists(SubscriptNode subscript | 
    subscript.getIndex() = indexNode |
    exists(Value targetValue |
      subscript.getObject().pointsTo(targetValue) and
      not has_custom_getitem(targetValue)
    )
  )
}

/**
 * Holds if `nodeInTry` is within a try block that catches TypeError. For example:
 *
 *    try:
 *       ... nodeInTry ...
 *    except TypeError:
 *       ...
 *
 * This predicate reduces false positives by identifying proper exception handling
 * for unhashable operations that would otherwise raise TypeError.
 */
// Checks if a node is protected by a TypeError handler
predicate typeerror_is_caught(ControlFlowNode nodeInTry) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(nodeInTry.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Detects unhandled unhashable operations in hashing or subscript contexts
from ControlFlowNode issueNode, ClassValue issueType, ControlFlowNode sourceNode
where
  not typeerror_is_caught(issueNode) and
  (
    explicitly_hashed(issueNode) and is_unhashable(issueNode, issueType, sourceNode)
    or
    unhashable_subscript(issueNode, issueType, sourceNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", issueType, issueType.getQualifiedName()