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
 * Identifies classes representing numpy array types.
 * Matches classes inheriting from numpy.ndarray or numpy.core.ndarray.
 */
predicate numpy_array_type(ClassValue arrayClass) {
  exists(ModuleValue numpyModule | 
    numpyModule.getName() = "numpy" or 
    numpyModule.getName() = "numpy.core" |
    arrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

/**
 * Determines if a value implements custom indexing behavior.
 * True for classes with custom __getitem__ method or numpy arrays.
 */
predicate has_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetValue.getClass())
}

/**
 * Locates control flow nodes passed directly to hash().
 */
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode callNode, GlobalVariable globalVar |
    callNode.getArg(0) = node and 
    callNode.getFunction().(NameNode).uses(globalVar) and 
    globalVar.getId() = "hash"
  )
}

/**
 * Checks if a subscript operation uses an unhashable index.
 * Requires the target object to lack custom indexing behavior.
 */
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value targetValue |
      subscriptOp.getObject().pointsTo(targetValue) and
      not has_custom_getitem(targetValue)
    )
  )
}

/**
 * Verifies if an object is unhashable.
 * Applies to new-style classes without __hash__ or with __hash__ = None.
 */
predicate is_unhashable(ControlFlowNode node, ClassValue targetClass, ControlFlowNode originNode) {
  exists(Value objValue | node.pointsTo(objValue, originNode) and objValue.getClass() = targetClass |
    (not targetClass.hasAttribute("__hash__") and 
     not targetClass.failedInference(_) and 
     targetClass.isNewStyle())
    or
    targetClass.lookup("__hash__") = Value::named("None")
  )
}

/**
 * Detects control flow nodes within try blocks catching TypeError.
 * Used to filter out cases where TypeError is explicitly handled.
 */
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query identifying unhandled unhashable operations
from ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode
where
  not typeerror_is_caught(node) and
  (
    explicitly_hashed(node) and 
    is_unhashable(node, unhashableClass, originNode)
    or
    unhashable_subscript(node, unhashableClass, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()