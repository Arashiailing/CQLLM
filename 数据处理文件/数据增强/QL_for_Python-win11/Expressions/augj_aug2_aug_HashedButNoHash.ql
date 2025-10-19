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
 * This analysis identifies unhashable objects used in hashing contexts.
 * It assumes that any indexing operation where the value is not a sequence or numpy array involves hashing.
 * Sequences require integer indices (which are hashable), so they don't need special handling.
 * Numpy arrays may use list indices (which are unhashable) and require special consideration.
 */

// Identifies numpy array types by checking inheritance from numpy.ndarray
predicate is_numpy_array_type(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyModuleValue | 
    numpyModuleValue.getName() = "numpy" or numpyModuleValue.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = numpyModuleValue.attr("ndarray")
  )
}

// Determines if a value has a custom __getitem__ implementation
predicate has_custom_getitem_method(Value containerObject) {
  containerObject.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array_type(containerObject.getClass())
}

// Detects explicit hash() function calls
predicate is_explicitly_hashed(ControlFlowNode hashedNode) {
  exists(CallNode hashFunctionCall, GlobalVariable hashGlobalVariable |
    hashFunctionCall.getArg(0) = hashedNode and 
    hashFunctionCall.getFunction().(NameNode).uses(hashGlobalVariable) and 
    hashGlobalVariable.getId() = "hash"
  )
}

// Checks if a subscript operation uses an unhashable index
predicate uses_unhashable_index(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable_object(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value containerObject |
      subscriptNode.getObject().pointsTo(containerObject) and
      not has_custom_getitem_method(containerObject)
    )
  )
}

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode targetNode, ClassValue targetClass, ControlFlowNode originNode) {
  exists(Value objectValue | 
    targetNode.pointsTo(objectValue, originNode) and 
    objectValue.getClass() = targetClass
  |
    (not targetClass.hasAttribute("__hash__") and 
     not targetClass.failedInference(_) and 
     targetClass.isNewStyle())
    or
    targetClass.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Identifies nodes protected by TypeError-catching try blocks.
 * This reduces false positives by excluding cases where:
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 * Since unhashable operations throw TypeError, explicit handling indicates intentional behavior.
 */
predicate is_inside_typeerror_handler(ControlFlowNode currentNode) {
  exists(Try tryStatement |
    tryStatement.getBody().contains(currentNode.getNode()) and
    tryStatement.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode problematicNode, ClassValue problematicClass, ControlFlowNode sourceNode
where
  not is_inside_typeerror_handler(problematicNode) and
  (
    (is_explicitly_hashed(problematicNode) and is_unhashable_object(problematicNode, problematicClass, sourceNode))
    or
    uses_unhashable_index(problematicNode, problematicClass, sourceNode)
  )
select problematicNode.getNode(), "This $@ of $@ is unhashable.", sourceNode, "instance", problematicClass, problematicClass.getQualifiedName()