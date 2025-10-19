/**
 * @name Modification of dictionary returned by locals()
 * @description Detects attempts to modify the dictionary returned by locals() which do not affect the actual local variables.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// 判断控制流节点是否引用了 locals() 函数的调用结果
predicate referencesLocalsCall(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检查是否存在对 locals() 返回字典的字典操作（下标赋值或删除）
predicate isDictionaryModification(ControlFlowNode modNode) {
    exists(SubscriptNode subscriptNode |
        subscriptNode = modNode and
        referencesLocalsCall(subscriptNode.getObject()) and
        (subscriptNode.isStore() or subscriptNode.isDelete())
    )
}

// 检查是否存在对 locals() 返回字典的方法调用（会修改字典内容的方法）
predicate isMethodCallModification(ControlFlowNode modNode) {
    exists(CallNode callNode, AttrNode attributeNode, string methodName |
        callNode = modNode and
        attributeNode = callNode.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// 判断是否存在对 locals() 返回字典的任何修改操作
predicate modifiesLocalsDictionary(ControlFlowNode modNode) {
    isDictionaryModification(modNode) or
    isMethodCallModification(modNode)
}

from AstNode astNode, ControlFlowNode modNode
where
    // 查找修改 locals() 返回字典的操作
    modifiesLocalsDictionary(modNode) and
    // 获取与控制流节点对应的 AST 节点
    astNode = modNode.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not astNode.getScope() instanceof ModuleScope
// 输出结果并附带警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."