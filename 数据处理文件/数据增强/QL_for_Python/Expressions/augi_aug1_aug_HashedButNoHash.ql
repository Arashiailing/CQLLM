/**
 * @name Unhashable object hashed
 * @description Detects unhashable objects used in hashing contexts, which cause runtime TypeErrors.
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
 * Identifies unhashable objects in hashing contexts:
 * 1. Direct hash() function calls
 * 2. Dictionary/set operations requiring hashable keys
 * 
 * Key detection logic:
 * - Sequences only accept integer indices (always hashable)
 * - NumPy arrays support non-hashable indices (e.g., lists)
 * - Objects are unhashable if they lack __hash__ or have __hash__ = None
 */

// Determines if a class represents a NumPy array type
predicate is_numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value implements custom __getitem__ logic
predicate has_custom_getitem_method(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(targetValue.getClass())
}

// Detects values passed as arguments to hash() function
predicate is_explicitly_hashed(ControlFlowNode hashedNode) {
  exists(CallNode hashFunctionCall, GlobalVariable hashGlobalVariable |
    hashFunctionCall.getArg(0) = hashedNode and 
    hashFunctionCall.getFunction().(NameNode).uses(hashGlobalVariable) and 
    hashGlobalVariable.getId() = "hash"
  )
}

// Identifies subscript operations using unhashable indices
predicate has_unhashable_subscript(ControlFlowNode subscriptIndexNode, ClassValue unhashableClass, ControlFlowNode sourceNode) {
  exists(SubscriptNode subscriptOperation, Value targetValue |
    subscriptOperation.getIndex() = subscriptIndexNode and
    subscriptOperation.getObject().pointsTo(targetValue) and
    not has_custom_getitem_method(targetValue) and
    is_unhashable_object(subscriptIndexNode, unhashableClass, sourceNode)
  )
}

// Determines if an object is unhashable
predicate is_unhashable_object(ControlFlowNode objectNode, ClassValue objectClass, ControlFlowNode sourceNode) {
  exists(Value value | 
    objectNode.pointsTo(value, sourceNode) and 
    value.getClass() = objectClass and
    (
      (objectClass.isNewStyle() and 
       not objectClass.failedInference(_) and 
       not objectClass.hasAttribute("__hash__"))
      or
      objectClass.lookup("__hash__") = Value::named("None")
    )
  )
}

/**
 * Checks if a node is inside a try block catching TypeError.
 * Used to filter false positives where TypeError is handled.
 */
predicate is_inside_typeerror_handler(ControlFlowNode targetNode) {
  exists(Try tryStatement |
    tryStatement.getBody().contains(targetNode.getNode()) and
    tryStatement.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Find unhandled unhashable objects in hashing contexts
from ControlFlowNode issueNode, ClassValue unhashableClass, ControlFlowNode sourceNode
where
  not is_inside_typeerror_handler(issueNode) and
  (
    (is_explicitly_hashed(issueNode) and is_unhashable_object(issueNode, unhashableClass, sourceNode))
    or
    has_unhashable_subscript(issueNode, unhashableClass, sourceNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", unhashableClass, unhashableClass.getQualifiedName()