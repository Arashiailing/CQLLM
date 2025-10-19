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

/**
 * This assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * For sequences, the index must be an int, which are hashable, so we don't need to treat them specially.
 * For numpy arrays, the index may be a list, which are not hashable and needs to be treated specially.
 */

// Determines if a class represents a numpy array type
predicate is_numpy_array(ClassValue arr) {
  exists(ModuleValue np | np.getName() = "numpy" or np.getName() = "numpy.core" |
    arr.getASuperType() = np.attr("ndarray")
  )
}

// Checks if a value has a custom __getitem__ method
predicate has_custom_getitem_method(Value val) {
  val.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array(val.getClass())
}

// Identifies control flow nodes that are explicitly hashed
predicate is_explicitly_hashed(ControlFlowNode node) {
  exists(CallNode call, GlobalVariable hashFunc |
    call.getArg(0) = node and 
    call.getFunction().(NameNode).uses(hashFunc) and 
    hashFunc.getId() = "hash"
  )
}

// Determines if a subscript operation involves an unhashable object
predicate is_unhashable_subscript(ControlFlowNode indexNode, ClassValue cls, ControlFlowNode originNode) {
  is_unhashable(indexNode, cls, originNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexNode |
    exists(Value containerValue |
      subscript.getObject().pointsTo(containerValue) and
      not has_custom_getitem_method(containerValue)
    )
  )
}

// Checks if an object is unhashable
predicate is_unhashable(ControlFlowNode node, ClassValue cls, ControlFlowNode originNode) {
  exists(Value v | node.pointsTo(v, originNode) and v.getClass() = cls |
    (not cls.hasAttribute("__hash__") and not cls.failedInference(_) and cls.isNewStyle())
    or
    cls.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Holds if `node` is inside a `try` that catches `TypeError`. For example:
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
// Checks if a control flow node is inside a try block catching TypeError
predicate is_typeerror_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Finds uncaught hashing or subscript operations on unhashable objects
from ControlFlowNode node, ClassValue cls, ControlFlowNode originNode
where
  not is_typeerror_caught(node) and
  (
    is_explicitly_hashed(node) and is_unhashable(node, cls, originNode)
    or
    is_unhashable_subscript(node, cls, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", cls, cls.getQualifiedName()