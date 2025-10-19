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
 * 查询逻辑说明：
 * 1. 识别不可哈希对象：通过检查类是否缺少__hash__方法或显式设置为None
 * 2. 检测哈希操作场景：包括显式hash()调用和字典/集合下标操作
 * 3. 排除误报情况：跳过numpy数组索引和已捕获TypeError的代码块
 */

// 判断类是否为numpy数组类型
predicate is_numpy_array(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyModule | numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core" |
    numpyArrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// 检查值是否具有自定义__getitem__方法（包括numpy数组）
predicate has_custom_getitem(Value containerValue) {
  containerValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  is_numpy_array(containerValue.getClass())
}

// 识别显式哈希操作节点
predicate is_explicitly_hashed(ControlFlowNode hashedCfNode) {
  exists(CallNode hashCallNode, GlobalVariable hashGlobal |
    hashCallNode.getArg(0) = hashedCfNode and 
    hashCallNode.getFunction().(NameNode).uses(hashGlobal) and 
    hashGlobal.getId() = "hash"
  )
}

// 判断对象是否不可哈希
predicate is_unhashable(ControlFlowNode objCfNode, ClassValue objCls, ControlFlowNode sourceCfNode) {
  exists(Value objValue | objCfNode.pointsTo(objValue, sourceCfNode) and objValue.getClass() = objCls |
    (not objCls.hasAttribute("__hash__") and 
     not objCls.failedInference(_) and 
     objCls.isNewStyle())
    or
    objCls.lookup("__hash__") = Value::named("None")
  )
}

// 检测不可哈希对象用于下标操作
predicate is_unhashable_subscript(ControlFlowNode indexNode, ClassValue unhashableCls, ControlFlowNode sourceCfNode) {
  is_unhashable(indexNode, unhashableCls, sourceCfNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = indexNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not has_custom_getitem(containerValue)
    )
  )
}

/**
 * 检查节点是否位于捕获TypeError的try块内
 * 用于消除已处理异常的误报
 */
predicate is_typeerror_caught(ControlFlowNode node) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(node.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 主查询：查找未处理的不可哈希对象哈希操作
from ControlFlowNode problematicCfNode, ClassValue problematicCls, ControlFlowNode sourceCfNode
where
  not is_typeerror_caught(problematicCfNode) and
  (
    is_explicitly_hashed(problematicCfNode) and is_unhashable(problematicCfNode, problematicCls, sourceCfNode)
    or
    is_unhashable_subscript(problematicCfNode, problematicCls, sourceCfNode)
  )
select problematicCfNode.getNode(), "这个 $@ 的 $@ 是不可哈希的。", sourceCfNode, "实例", problematicCls, problematicCls.getQualifiedName()