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
predicate isLocalsCallSource(ControlFlowNode node) { 
    node.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检查是否存在通过下标操作修改 locals() 返回字典的情况
predicate isSubscriptModification(ControlFlowNode opNode) {
    // 获取下标操作的对象并验证其来自 locals() 调用
    isLocalsCallSource(opNode.(SubscriptNode).getObject()) and
    // 确认是存储或删除操作
    (opNode.isStore() or opNode.isDelete())
}

// 检查是否存在通过方法调用修改 locals() 返回字典的情况
predicate isMethodModification(ControlFlowNode opNode) {
    exists(string methodName, AttrNode attrNode |
        // 获取方法调用的属性节点
        attrNode = opNode.(CallNode).getFunction() and
        // 验证属性对象来自 locals() 调用
        isLocalsCallSource(attrNode.getObject(methodName))
    |
        // 检查方法名是否在修改字典的方法列表中
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// 检查是否存在对 locals() 返回字典的任何修改操作
predicate hasLocalsModification(ControlFlowNode opNode) {
    isSubscriptModification(opNode) or
    isMethodModification(opNode)
}

// 主查询：查找并报告对 locals() 返回字典的修改操作
from AstNode astNode, ControlFlowNode opNode
where
    // 确认存在对 locals() 返回字典的修改
    hasLocalsModification(opNode) and
    // 获取与控制流节点对应的 AST 节点
    astNode = opNode.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not astNode.getScope() instanceof ModuleScope
// 选择结果并附加警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."