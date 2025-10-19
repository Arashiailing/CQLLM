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

// 检查类是否继承自numpy.ndarray或numpy.core.ndarray
predicate numpy_array_type(ClassValue numpyArrayType) {
  exists(ModuleValue npModule | npModule.getName() = "numpy" or npModule.getName() = "numpy.core" |
    numpyArrayType.getASuperType() = npModule.attr("ndarray")
  )
}

// 检查值是否有自定义__getitem__实现（包括numpy数组）
predicate has_custom_getitem(Value targetVal) {
  targetVal.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetVal.getClass())
}

// 识别作为内置hash()函数参数的节点
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashGlobal |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// 检测在非自定义容器中用作下标的不可哈希对象
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode originPoint) {
  is_unhashable(indexNode, unhashableCls, originPoint) and
  exists(SubscriptNode subscriptOperation | subscriptOperation.getIndex() = indexNode |
    exists(Value containerObj |
      subscriptOperation.getObject().pointsTo(containerObj) and
      not has_custom_getitem(containerObj)
    )
  )
}

// 判断节点是否指向不可哈希类（缺少__hash__或__hash__=None）
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableCls, ControlFlowNode originPoint) {
  exists(Value pointedValue | node.pointsTo(pointedValue, originPoint) and pointedValue.getClass() = unhashableCls |
    (not unhashableCls.hasAttribute("__hash__") and 
     not unhashableCls.failedInference(_) and 
     unhashableCls.isNewStyle())
    or
    unhashableCls.lookup("__hash__") = Value::named("None")
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
// 检查节点是否在捕获TypeError的try块中
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 主查询：检测未处理的不可哈希操作
from ControlFlowNode targetNode, ClassValue unhashableType, ControlFlowNode originNode
where
  not typeerror_is_caught(targetNode) and
  (
    explicitly_hashed(targetNode) and is_unhashable(targetNode, unhashableType, originNode)
    or
    unhashable_subscript(targetNode, unhashableType, originNode)
  )
select targetNode.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableType, unhashableType.getQualifiedName()