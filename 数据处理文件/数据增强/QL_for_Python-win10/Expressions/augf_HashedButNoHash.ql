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

// Check if a class represents a numpy array type
predicate isNumpyArrayType(ClassValue arrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// Check if a value has a custom __getitem__ method
predicate hasCustomGetitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(value.getClass())
}

// Check if a control flow node is explicitly hashed
predicate isExplicitlyHashed(ControlFlowNode node) {
  exists(CallNode call, GlobalVariable hashFunc |
    call.getArg(0) = node and 
    call.getFunction().(NameNode).uses(hashFunc) and 
    hashFunc.getId() = "hash"
  )
}

// Check if an object is unhashable
predicate isUnhashable(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  exists(Value val | 
    node.pointsTo(val, origin) and 
    val.getClass() = cls |
    (not cls.hasAttribute("__hash__") and 
     not cls.failedInference(_) and 
     cls.isNewStyle())
    or
    cls.lookup("__hash__") = Value::named("None")
  )
}

// Check if a subscript operation involves an unhashable object
predicate isUnhashableSubscript(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  isUnhashable(node, cls, origin) and
  exists(SubscriptNode subscript | subscript.getIndex() = node |
    exists(Value container |
      subscript.getObject().pointsTo(container) and
      not hasCustomGetitem(container)
    )
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
// Check if a control flow node is inside a try block catching TypeError
predicate isTypeErrorCaught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Query for uncaught hashing or subscript operations on unhashable objects
from ControlFlowNode node, ClassValue cls, ControlFlowNode origin
where
  not isTypeErrorCaught(node) and
  (
    isExplicitlyHashed(node) and isUnhashable(node, cls, origin)
    or
    isUnhashableSubscript(node, cls, origin)
  )
select node.getNode(), "This $@ of $@ is unhashable.", origin, "instance", cls, cls.getQualifiedName()