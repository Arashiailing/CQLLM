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
predicate numpyArrayType(ClassValue numpyArray) {
  exists(ModuleValue np | np.getName() = "numpy" or np.getName() = "numpy.core" |
    numpyArray.getASuperType() = np.attr("ndarray")
  )
}

// Checks if a value has a custom __getitem__ method
predicate hasCustomGetitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpyArrayType(value.getClass())
}

// Identifies control flow nodes explicitly passed to hash()
predicate explicitlyHashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashFunc |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashFunc) and 
    hashFunc.getId() = "hash"
  )
}

// Detects subscript operations involving unhashable objects
predicate unhashableSubscript(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  isUnhashable(node, cls, origin) and
  exists(SubscriptNode subscript | subscript.getIndex() = node |
    exists(Value containerValue |
      subscript.getObject().pointsTo(containerValue) and
      not hasCustomGetitem(containerValue)
    )
  )
}

// Determines if an object is unhashable
predicate isUnhashable(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  exists(Value v | node.pointsTo(v, origin) and v.getClass() = cls |
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
// Checks if a control flow node is within a try block catching TypeError
predicate typeErrorIsCaught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Query for uncaught hashing/subscript operations on unhashable objects
from ControlFlowNode node, ClassValue cls, ControlFlowNode origin
where
  not typeErrorIsCaught(node) and
  (
    explicitlyHashed(node) and isUnhashable(node, cls, origin)
    or
    unhashableSubscript(node, cls, origin)
  )
select node.getNode(), "This $@ of $@ is unhashable.", origin, "instance", cls, cls.getQualifiedName()