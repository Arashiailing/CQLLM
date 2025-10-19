/**
 * @name Modification of dictionary returned by locals()
 * @description Detects modifications to the dictionary returned by locals(),
 *              which do not affect the actual local variables in a function.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// 检查控制流节点是否关联到 locals() 函数调用
predicate isLocalsCallSource(ControlFlowNode cfNode) { 
    cfNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检查是否存在通过下标操作修改 locals() 返回字典的情况
predicate isSubscriptModification(ControlFlowNode modNode) {
    // 获取下标操作的对象并验证其来自 locals() 调用
    isLocalsCallSource(modNode.(SubscriptNode).getObject()) and
    // 确认是存储或删除操作
    (modNode.isStore() or modNode.isDelete())
}

// 检查是否存在通过方法调用修改 locals() 返回字典的情况
predicate isMethodModification(ControlFlowNode modNode) {
    exists(string method, AttrNode attributeNode |
        // 获取方法调用的属性节点
        attributeNode = modNode.(CallNode).getFunction() and
        // 验证属性对象来自 locals() 调用
        isLocalsCallSource(attributeNode.getObject(method))
    |
        // 检查方法名是否在修改字典的方法列表中
        method in ["pop", "popitem", "update", "clear"]
    )
}

// 检查是否存在对 locals() 返回字典的任何修改操作
predicate hasLocalsModification(ControlFlowNode modNode) {
    isSubscriptModification(modNode) or
    isMethodModification(modNode)
}

// 主查询：查找并报告对 locals() 返回字典的修改操作
from AstNode targetNode, ControlFlowNode modNode
where
    // 确认存在对 locals() 返回字典的修改
    hasLocalsModification(modNode) and
    // 获取与控制流节点对应的 AST 节点
    targetNode = modNode.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not targetNode.getScope() instanceof ModuleScope
// 选择结果并附加警告信息
select targetNode, "Modification of the locals() dictionary will have no effect on the local variables."