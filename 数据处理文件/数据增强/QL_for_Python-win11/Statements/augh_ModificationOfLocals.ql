/**
 * @name Modification of dictionary returned by locals()
 * @description Modifications of the dictionary returned by locals() are not propagated to the local variables of a function.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/modification-of-locals
 */

import python

// 判断控制流节点是否关联到 locals() 函数调用
predicate isLocalsOrigin(ControlFlowNode node) { 
    node.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检测对 locals() 返回字典的修改操作
predicate hasLocalsModification(ControlFlowNode flowNode) {
    // 情况1：下标操作（字典项赋值或删除）
    isLocalsOrigin(flowNode.(SubscriptNode).getObject()) and
    (flowNode.isStore() or flowNode.isDelete())
    // 情况2：调用字典修改方法
    or
    exists(string methodName, AttrNode attributeNode |
        attributeNode = flowNode.(CallNode).getFunction() and
        isLocalsOrigin(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// 查询所有符合条件的 AST 节点
from AstNode astNode, ControlFlowNode flowNode
where
    // 存在对 locals() 字典的修改操作
    hasLocalsModification(flowNode) and
    // 关联 AST 节点与控制流节点
    astNode = flowNode.getNode() and
    // 排除模块级别作用域（locals() 等同于 globals()）
    not astNode.getScope() instanceof ModuleScope
// 输出结果和警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."