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
predicate is_numpy_array_type(ClassValue cls) {
  exists(ModuleValue numpyMod | 
    (numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core") and
    cls.getASuperType() = numpyMod.attr("ndarray")
  )
}

// Determines if a value has a custom __getitem__ implementation
predicate has_custom_getitem_method(Value container) {
  // Check for custom __getitem__ method
  container.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  // Or if it's a numpy array type
  is_numpy_array_type(container.getClass())
}

// Detects explicit hash() function calls
predicate is_explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// Core predicate to identify unhashable objects
predicate is_unhashable_object(ControlFlowNode node, ClassValue cls, ControlFlowNode origin) {
  exists(Value val | 
    node.pointsTo(val, origin) and 
    val.getClass() = cls and
    (
      // Case 1: No __hash__ method defined (and is new-style class)
      (not cls.hasAttribute("__hash__") and 
       not cls.failedInference(_) and 
       cls.isNewStyle())
      or
      // Case 2: __hash__ explicitly set to None
      cls.lookup("__hash__") = Value::named("None")
    )
  )
}

// Checks if a subscript operation uses an unhashable index
predicate uses_unhashable_index(ControlFlowNode index, ClassValue unhashableCls, ControlFlowNode source) {
  // Verify the index is unhashable
  is_unhashable_object(index, unhashableCls, source) and
  // Check usage in subscript operation
  exists(SubscriptNode subscript | 
    subscript.getIndex() = index and
    exists(Value container |
      subscript.getObject().pointsTo(container) and
      // Container must not have custom indexing behavior
      not has_custom_getitem_method(container)
    )
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
predicate is_inside_typeerror_handler(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query: Finds unhandled unhashable operations
from ControlFlowNode node, ClassValue cls, ControlFlowNode source
where
  // Exclude nodes inside TypeError handlers
  not is_inside_typeerror_handler(node) and
  (
    // Case 1: Explicit hash() call with unhashable object
    (is_explicitly_hashed(node) and is_unhashable_object(node, cls, source))
    or
    // Case 2: Unhashable index in subscript operation
    uses_unhashable_index(node, cls, source)
  )
select node.getNode(), "This $@ of $@ is unhashable.", source, "instance", cls, cls.getQualifiedName()