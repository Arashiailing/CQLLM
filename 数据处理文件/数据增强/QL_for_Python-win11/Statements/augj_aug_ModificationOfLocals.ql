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

// 检查控制流节点是否引用了 locals() 函数的调用结果
predicate referencesLocalsCall(ControlFlowNode controlFlowNode) { 
    controlFlowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检查是否存在对 locals() 返回字典的修改操作（包括字典操作和方法调用）
predicate modifiesLocalsDictionary(ControlFlowNode modificationNode) {
    // 情况1：通过下标操作修改字典（赋值或删除）
    exists(SubscriptNode subscriptNode |
        subscriptNode = modificationNode and
        referencesLocalsCall(subscriptNode.getObject()) and
        (subscriptNode.isStore() or subscriptNode.isDelete())
    )
    or
    // 情况2：调用修改字典内容的方法
    exists(CallNode callNode, AttrNode attributeNode, string methodName |
        callNode = modificationNode and
        attributeNode = callNode.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

from AstNode astNode, ControlFlowNode modificationNode
where
    // 查找修改 locals() 返回字典的操作
    modifiesLocalsDictionary(modificationNode) and
    // 获取与控制流节点对应的 AST 节点
    astNode = modificationNode.getNode() and
    // 排除模块级别作用域（locals() 等同于 globals()）
    not astNode.getScope() instanceof ModuleScope
// 输出结果并附带警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."