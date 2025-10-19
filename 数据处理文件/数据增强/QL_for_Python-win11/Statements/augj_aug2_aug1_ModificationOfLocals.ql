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

// 判断控制流节点是否关联到 locals() 函数调用
predicate isLocalsReference(ControlFlowNode cfgNode) { 
    cfgNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 检测通过下标操作修改 locals() 返回字典的情况
predicate isSubscriptUpdate(ControlFlowNode subscriptOp) {
    // 验证下标操作的对象来自 locals() 调用
    isLocalsReference(subscriptOp.(SubscriptNode).getObject()) and
    // 确认是存储或删除操作
    (subscriptOp.isStore() or subscriptOp.isDelete())
}

// 检测通过方法调用修改 locals() 返回字典的情况
predicate isMethodUpdate(ControlFlowNode methodCall) {
    exists(string methodName, AttrNode attrNode |
        // 获取方法调用的属性节点
        attrNode = methodCall.(CallNode).getFunction() and
        // 验证属性对象来自 locals() 调用
        isLocalsReference(attrNode.getObject(methodName))
    |
        // 检查方法名是否在修改字典的方法集合中
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// 主查询：定位并报告对 locals() 返回字典的修改操作
from AstNode astNode, ControlFlowNode modifyOperation
where
    // 检测所有可能的修改操作（下标更新或方法调用更新）
    (isSubscriptUpdate(modifyOperation) or isMethodUpdate(modifyOperation)) and
    // 获取与控制流节点对应的 AST 节点
    astNode = modifyOperation.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not astNode.getScope() instanceof ModuleScope
// 选择结果并附加警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."