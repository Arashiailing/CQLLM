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

// 检查类是否为numpy数组类型（继承自numpy.ndarray或numpy.core.ndarray）
predicate numpy_array_type(ClassValue numpyArrayClass) {
  exists(ModuleValue np | np.getName() = "numpy" or np.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = np.attr("ndarray")
  )
}

// 检查值是否具有自定义__getitem__方法（包括numpy数组）
predicate has_custom_getitem(Value value) {
  value.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(value.getClass())
}

// 检查控制流节点是否作为参数传递给内置hash函数（显式哈希）
predicate explicitly_hashed(ControlFlowNode node) {
  exists(CallNode hashCall, GlobalVariable hashVar |
    hashCall.getArg(0) = node and 
    hashCall.getFunction().(NameNode).uses(hashVar) and 
    hashVar.getId() = "hash"
  )
}

// 检查下标操作中的索引是否为不可哈希对象，且操作对象没有自定义__getitem__
predicate unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableClass, ControlFlowNode originNode) {
  is_unhashable(indexNode, unhashableClass, originNode) and
  exists(SubscriptNode subscriptOp | subscriptOp.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptOp.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

// 检查控制流节点指向的值是否属于不可哈希类（无__hash__或__hash__为None）
predicate is_unhashable(ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode) {
  exists(Value targetValue | node.pointsTo(targetValue, originNode) and targetValue.getClass() = unhashableClass |
    (not unhashableClass.hasAttribute("__hash__") and 
     not unhashableClass.failedInference(_) and 
     unhashableClass.isNewStyle())
    or
    unhashableClass.lookup("__hash__") = Value::named("None")
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
// 检查控制流节点是否位于捕获TypeError的try块内（排除已处理异常）
predicate typeerror_is_caught(ControlFlowNode node) {
  exists(Try tryBlock |
    tryBlock.getBody().contains(node.getNode()) and
    tryBlock.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 查询未捕获的不可哈希对象哈希操作或下标操作
from ControlFlowNode node, ClassValue unhashableClass, ControlFlowNode originNode
where
  not typeerror_is_caught(node) and
  (
    explicitly_hashed(node) and is_unhashable(node, unhashableClass, originNode)
    or
    unhashable_subscript(node, unhashableClass, originNode)
  )
select node.getNode(), "This $@ of $@ is unhashable.", originNode, "instance", unhashableClass, unhashableClass.getQualifiedName()