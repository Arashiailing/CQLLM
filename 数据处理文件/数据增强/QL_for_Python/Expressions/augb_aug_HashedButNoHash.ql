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

// Checks whether a given class is a numpy array type
predicate numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue numpyModule | numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Determines if a value possesses a custom __getitem__ method
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

// Finds control flow nodes that are subject to explicit hashing
predicate explicitly_hashed(ControlFlowNode targetNode) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = targetNode and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Verifies that an object is unhashable
predicate is_unhashable(ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode sourceNode) {
  exists(Value val | targetNode.pointsTo(val, sourceNode) and val.getClass() = unhashableType |
    not unhashableType.hasAttribute("__hash__") and 
    not unhashableType.failedInference(_) and 
    unhashableType.isNewStyle()
    or
    unhashableType.lookup("__hash__") = Value::named("None")
  )
}

// Checks if a subscript operation uses an unhashable object as an index
predicate unhashable_subscript(ControlFlowNode subscriptIndex, ClassValue unhashableType, ControlFlowNode sourceNode) {
  is_unhashable(subscriptIndex, unhashableType, sourceNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = subscriptIndex |
    exists(Value targetValue |
      subscript.getObject().pointsTo(targetValue) and
      not has_custom_getitem(targetValue)
    )
  )
}

/**
 * Holds if `targetNode` is located within a `try` block that catches `TypeError`. For instance:
 *
 *    try:
 *       ... targetNode ...
 *    except TypeError:
 *       ...
 *
 * This predicate helps in reducing false positives. When the `hash` function is invoked
 * on an unhashable object, a `TypeError` is raised. However, if the exception is caught
 * and handled appropriately, it is not considered a bug.
 */
// Determines if a control flow node is inside a try block that handles TypeError
predicate typeerror_is_caught(ControlFlowNode targetNode) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(targetNode.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Identifies unhandled hashing or subscript operations on unhashable objects
from ControlFlowNode issueNode, ClassValue issueType, ControlFlowNode sourceNode
where
  not typeerror_is_caught(issueNode) and
  (
    explicitly_hashed(issueNode) and is_unhashable(issueNode, issueType, sourceNode)
    or
    unhashable_subscript(issueNode, issueType, sourceNode)
  )
select issueNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", issueType, issueType.getQualifiedName()