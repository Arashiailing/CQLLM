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
 * This analysis identifies unhashable objects used in contexts requiring hashability.
 * Hashing occurs in two primary scenarios:
 * 1. Explicit hash() function calls
 * 2. Subscript operations where the index must be hashable
 * Special handling for numpy arrays is included since they allow non-hashable indices
 */

// Identifies numpy array types by checking inheritance from numpy.ndarray
predicate is_numpy_array(ClassValue arrayClass) {
  exists(ModuleValue numpyModule | numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value implements custom __getitem__ behavior
predicate has_custom_item_access(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array(targetValue.getClass())
}

// Detects explicit hash() function calls on a target node
predicate is_explicitly_hashed(ControlFlowNode hashedNode) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = hashedNode and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Verifies an object is unhashable by checking its __hash__ implementation
predicate is_unhashable_object(ControlFlowNode unhashableNode, ClassValue unhashableType, ControlFlowNode originNode) {
  exists(Value val | unhashableNode.pointsTo(val, originNode) and val.getClass() = unhashableType |
    // Case 1: No __hash__ method defined (and not a failed inference)
    (not unhashableType.hasAttribute("__hash__") and 
     not unhashableType.failedInference(_) and 
     unhashableType.isNewStyle())
    or
    // Case 2: Explicit __hash__ = None
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Checks if a subscript operation uses an unhashable index
predicate uses_unhashable_index(ControlFlowNode indexNode, ClassValue unhashableType, ControlFlowNode originNode) {
  is_unhashable_object(indexNode, unhashableType, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value targetValue |
      subscriptOp.getObject().pointsTo(targetValue) and
      // Skip objects with custom __getitem__ (e.g., numpy arrays)
      not has_custom_item_access(targetValue)
    )
  )
}

/**
 * Identifies nodes protected by TypeError handlers. For example:
 * 
 *    try:
 *       ... protected_node ...
 *    except TypeError:
 *       ...
 * 
 * This reduces false positives by excluding cases where the TypeError
 * from unhashable operations is explicitly handled.
 */
predicate is_typeerror_handled(ControlFlowNode protectedNode) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(protectedNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable operations
from ControlFlowNode issueNode, ClassValue issueType, ControlFlowNode sourceNode
where
  not is_typeerror_handled(issueNode) and
  (
    // Case 1: Explicit hash() call on unhashable object
    is_explicitly_hashed(issueNode) and is_unhashable_object(issueNode, issueType, sourceNode)
    or
    // Case 2: Unhashable object used as subscript index
    uses_unhashable_index(issueNode, issueType, sourceNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", issueType, issueType.getQualifiedName()