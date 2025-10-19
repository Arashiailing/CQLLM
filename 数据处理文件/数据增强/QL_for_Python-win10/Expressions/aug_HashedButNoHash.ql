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
 * This assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so we don't need to treat them specially.
 * For numpy arrays, the index may be a list, which are not hashable and needs to be treated specially.
 */

// Determines if a class represents a numpy array type
predicate numpy_array_type(ClassValue ndarrayType) {
  exists(ModuleValue numpyModule | numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    ndarrayType.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Checks if a value has a custom __getitem__ method
predicate has_custom_getitem(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(val.getClass())
}

// Identifies control flow nodes that are explicitly hashed
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Determines if a subscript operation involves an unhashable object
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexNode |
    exists(Value targetValue |
      subscript.getObject().pointsTo(targetValue) and
      not has_custom_getitem(targetValue)
    )
  )
}

// Checks if an object is unhashable
predicate is_unhashable(ControlFlowNode node, ClassValue targetClass, ControlFlowNode originNode) {
  exists(Value val | node.pointsTo(val, originNode) and val.getClass() = targetClass |
    not targetClass.hasAttribute("__hash__") and 
    not targetClass.failedInference(_) and 
    targetClass.isNewStyle()
    or
    targetClass.lookup("__hash__") = Value::named("None")
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
 * This predicate is used to eliminate false positive results. If `hash`
 * is called on an unhashable object then a `TypeError` will be thrown.
 * But this is not a bug if the code catches the `TypeError` and handles
 * it.
 */
// Checks if a control flow node is within a try block catching TypeError
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Finds unhandled hashing or subscript operations on unhashable objects
from ControlFlowNode problemNode, ClassValue problemClass, ControlFlowNode originNode
where
  not typeerror_is_caught(problemNode) and
  (
    explicitly_hashed(problemNode) and is_unhashable(problemNode, problemClass, originNode)
    or
    unhashable_subscript(problemNode, problemClass, originNode)
  )
select problemNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", problemClass, problemClass.getQualifiedName()