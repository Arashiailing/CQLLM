/**
 * @name 不可哈希对象被哈希
 * @description 对不可哈希的对象进行哈希操作会在运行时引发TypeError。
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
 * 本查询假设：任何索引操作中，如果索引值不是序列或numpy数组，则涉及哈希操作。
 * 对于序列，索引必须是整数（整数是可哈希的），因此不需要特殊处理。
 * 对于numpy数组，索引可能是列表（列表不可哈希），需要特殊处理。
 */

// 检查类是否继承自numpy的ndarray类型
predicate isNumpyArrayType(ClassValue numpyArrayClass) {
  exists(ModuleValue numpyModule | 
    (numpyModule.getName() = "numpy" or numpyModule.getName() = "numpy.core") |
    numpyArrayClass.getASuperType() = numpyModule.attr("ndarray")
  )
}

// 检查值是否具有自定义的__getitem__方法
predicate hasCustomGetitem(Value targetValue) {
  targetValue.getClass().lookup("__getitem__") instanceof PythonFunctionValue
  or
  isNumpyArrayType(targetValue.getClass())
}

// 检查控制流节点是否作为hash()函数的参数被显式哈希
predicate isExplicitlyHashed(ControlFlowNode cfNode) {
  exists(CallNode hashCall, GlobalVariable hashGlobalVar |
    hashCall.getArg(0) = cfNode and 
    hashCall.getFunction().(NameNode).uses(hashGlobalVar) and 
    hashGlobalVar.getId() = "hash"
  )
}

// 检查控制流节点是否指向不可哈希对象
predicate isUnhashable(ControlFlowNode cfNode, ClassValue objClass, ControlFlowNode originNode) {
  exists(Value pointedValue | 
    cfNode.pointsTo(pointedValue, originNode) and 
    pointedValue.getClass() = objClass |
    (not objClass.hasAttribute("__hash__") and 
     not objClass.failedInference(_) and 
     objClass.isNewStyle())
    or
    objClass.lookup("__hash__") = Value::named("None")
  )
}

// 检查控制流节点是否在作为下标时使用了不可哈希对象
predicate isUnhashableSubscript(ControlFlowNode cfNode, ClassValue objClass, ControlFlowNode originNode) {
  isUnhashable(cfNode, objClass, originNode) and
  exists(SubscriptNode subscriptNode | subscriptNode.getIndex() = cfNode |
    exists(Value containerValue |
      subscriptNode.getObject().pointsTo(containerValue) and
      not hasCustomGetitem(containerValue)
    )
  )
}

/**
 * 检查控制流节点是否位于捕获TypeError的try块内。
 * 如果节点位于try块中，并且该try块有except TypeError子句，
 * 则认为该异常已被处理，不报告为问题。
 */
predicate isTypeErrorCaught(ControlFlowNode cfNode) {
  exists(Try tryStmt |
    tryStmt.getBody().contains(cfNode.getNode()) and
    tryStmt.getAHandler().getType().pointsTo(ClassValue::typeError())
  )
}

// 查询未捕获的不可哈希对象哈希操作
from ControlFlowNode node, ClassValue cls, ControlFlowNode origin
where
  not isTypeErrorCaught(node) and
  (
    isExplicitlyHashed(node) and isUnhashable(node, cls, origin)
    or
    isUnhashableSubscript(node, cls, origin)
  )
select node.getNode(), "This $@ of $@ is unhashable.", origin, "instance", cls, cls.getQualifiedName()