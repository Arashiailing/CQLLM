/**
 * @name Unhashable Object Hashed
 * @description Detects attempts to hash an unhashable object, which would cause a TypeError at runtime.
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
 * Checks whether a given class is a numpy array type, 
 * including those inheriting from numpy.ndarray or numpy.core.ndarray.
 */
predicate numpy_array_type(ClassValue ndarrayCls) {
  exists(ModuleValue numpyMod | 
    (numpyMod.getName() = "numpy" or numpyMod.getName() = "numpy.core") and
    ndarrayCls.getASuperType() = numpyMod.attr("ndarray")
  )
}

/**
 * Determines if a value has custom indexing behavior, 
 * such as a custom __getitem__ method or being a numpy array.
 */
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

/**
 * Finds control flow nodes that are explicitly passed as arguments 
 * to the built-in hash() function.
 */
predicate explicitly_hashed(ControlFlowNode cfNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = cfNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

/**
 * Identifies subscript operations that use an unhashable index, 
 * where the target object does not have custom indexing behavior.
 */
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscript | subscript.getIndex() = indexNode |
    exists(Value targetObj |
      subscript.getObject().pointsTo(targetObj) and
      not has_custom_getitem(targetObj)
    )
  )
}

/**
 * Determines if an object is unhashable, which is true for new-style classes 
 * that lack a __hash__ method or have __hash__ explicitly set to None.
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
 * Determines if a control flow node is within a try block that catches TypeError, 
 * used to filter out false positives where the TypeError is handled.
 */
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// Main query identifying unhandled unhashable operations
from ControlFlowNode problemCfNode, ClassValue problemCls, ControlFlowNode originCfNode
where
  not typeerror_is_caught(problemCfNode) and
  (
    explicitly_hashed(problemCfNode) and 
    is_unhashable(problemCfNode, problemCls, originCfNode)
    or
    unhashable_subscript(problemCfNode, problemCls, originCfNode)
  )
select problemCfNode.getNode(), "This $@ of $@ is unhashable.", originCfNode, "instance", problemCls, problemCls.getQualifiedName()