/**
 * @name 不可哈希对象被哈希
 * @description 对不可哈希对象进行哈希操作将在运行时导致TypeError。
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
 * 本查询假设任何索引操作，如果其值不是序列或numpy数组，则涉及哈希操作。
 * 对于序列，索引必须是整数（可哈希），因此无需特殊处理。
 * 对于numpy数组，索引可能是列表（不可哈希），需要特殊处理。
 */

// 检查类是否代表numpy数组类型
predicate numpy_array_type(ClassValue ndarrayCls) {
  exists(ModuleValue numpyModule | numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    ndarrayCls.getASuperType() = numpyModule.attr("ndarray")
  )
}

// 检查值是否具有自定义__getitem__方法
predicate has_custom_getitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  numpy_array_type(targetValue.getClass())
}

// 识别被显式哈希的控制流节点
predicate explicitly_hashed(ControlFlowNode hashedNode) {
  exists(CallNode hashFuncCall, GlobalVariable hashGlobalVar |
    hashFuncCall.getArg(0) = hashedNode and 
    hashFuncCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// 判断下标操作是否涉及不可哈希对象
predicate unhashable_subscript(ControlFlowNode subscriptIndexNode, ClassValue unhashableCls, ControlFlowNode originCfNode) {
  is_unhashable(subscriptIndexNode, unhashableCls, originCfNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = subscriptIndexNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

// 检查对象是否不可哈希
predicate is_unhashable(ControlFlowNode objNode, ClassValue objClass, ControlFlowNode originCfNode) {
  exists(Value objValue | objNode.pointsTo(objValue, originCfNode) and objValue.getClass() = objClass |
    (not objClass.hasAttribute("__hash__") and 
     not objClass.failedInference(_) and 
     objClass.isNewStyle())
    or
    objClass.lookup("__hash__") = Value::named("None")
  )
}

/**
 * 判断节点是否位于捕获TypeError的try块内。例如：
 *
 *    try:
 *       ... node ...
 *    except TypeError:
 *       ...
 *
 * 此谓词用于消除误报。如果对不可哈希对象调用hash()会抛出TypeError，
 * 但代码捕获并处理了该异常，则不是问题。
 */
// 检查控制流节点是否在捕获TypeError的try块内
predicate typeerror_is_caught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 查找未处理的不可哈希对象哈希或下标操作
from ControlFlowNode problematicNode, ClassValue problematicClass, ControlFlowNode originCfNode
where
  not typeerror_is_caught(problematicNode) and
  (
    explicitly_hashed(problematicNode) and is_unhashable(problematicNode, problematicClass, originCfNode)
    or
    unhashable_subscript(problematicNode, problematicClass, originCfNode)
  )
select problematicNode.getNode(), "这个 $@ 的 $@ 是不可哈希的。", originCfNode, "实例", problematicClass, problematicClass.getQualifiedName()