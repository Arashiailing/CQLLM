/**
 * @name Unhashable object hashed
 * @description Detects unhashable objects used in hashing contexts which cause runtime TypeErrors.
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
 * Identifies unhashable objects in hashing contexts. Assumes indexing operations
 * with non-sequence/non-numpy indices involve hashing. Sequences use integer indices
 * (hashable) and numpy arrays require special handling due to list indices.
 */

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode objNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  exists(Value val | 
    objNode.pointsTo(val, originNode) and 
    val.getClass() = unhashableCls and
    (
      // Case 1: Class lacks __hash__ implementation
      (not unhashableCls.hasAttribute("__hash__") and 
       not unhashableCls.failedInference(_) and 
       unhashableCls.isNewStyle())
      or
      // Case 2: Class explicitly sets __hash__ to None
      unhashableCls.lookup("__hash__") = Value::named("None")
    )
  )
}

// Identifies numpy array types through inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue numpyArrayCls) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayCls.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a container has custom __getitem__ implementation
predicate has_custom_getitem_method(Value containerVal) {
  containerVal.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(containerVal.getClass())
}

// Detects explicit hash() function calls
predicate is_explicitly_hashed(ControlFlowNode objNode) {
  exists(CallNode hashCallNode, GlobalVariable hashGlobalVar |
    hashCallNode.getArg(0) = objNode and 
    hashCallNode.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// Checks if subscript operation uses unhashable index
predicate uses_unhashable_index(ControlFlowNode idxNode, ClassValue unhashableCls, ControlFlowNode originNode) {
  is_unhashable_object(idxNode, unhashableCls, originNode) and
  exists(SubscriptNode subscrNode | 
    subscrNode.getIndex() = idxNode |
    exists(Value containerVal |
      subscrNode.getObject().pointsTo(containerVal) and
      not has_custom_getitem_method(containerVal)
    )
  )
}

/**
 * Identifies nodes protected by TypeError-catching try blocks.
 * Reduces false positives by excluding cases where:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Since unhashable operations throw TypeError, explicit handling indicates intentional behavior.
 */
predicate is_inside_typeerror_handler(ControlFlowNode objNode) {
  exists(Try tryExceptNode |
    tryExceptNode.getBody().contains(objNode.getNode()) and
    tryExceptNode.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode issueNode, ClassValue issueType, ControlFlowNode originNode
where
  not is_inside_typeerror_handler(issueNode) and
  (
    (is_explicitly_hashed(issueNode) and is_unhashable_object(issueNode, issueType, originNode))
    or
    uses_unhashable_index(issueNode, issueType, originNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", issueType, issueType.getQualifiedName()