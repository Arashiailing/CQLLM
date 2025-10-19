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

// 判断控制流节点是否关联到 locals() 函数的调用
predicate isLocalsCallSource(ControlFlowNode controlFlowNode) { 
    controlFlowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

// 识别通过下标操作对 locals() 返回字典进行的修改
predicate isSubscriptModification(ControlFlowNode modificationNode) {
    // 验证被下标操作的对象来源于 locals() 调用
    isLocalsCallSource(modificationNode.(SubscriptNode).getObject()) and
    // 确认该操作是存储或删除操作
    (modificationNode.isStore() or modificationNode.isDelete())
}

// 识别通过方法调用对 locals() 返回字典进行的修改
predicate isMethodModification(ControlFlowNode modificationNode) {
    exists(string methodName, AttrNode attributeNode |
        // 提取表示被调用方法的属性节点
        attributeNode = modificationNode.(CallNode).getFunction() and
        // 验证调用方法的对象来源于 locals()
        isLocalsCallSource(attributeNode.getObject(methodName))
    |
        // 检查方法名是否为会修改字典的方法之一
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

// 组合检查对 locals() 返回字典的任何类型修改操作
predicate hasLocalsModification(ControlFlowNode modificationNode) {
    isSubscriptModification(modificationNode) or
    isMethodModification(modificationNode)
}

// 主查询：查找并报告对 locals() 返回字典的修改操作
from AstNode astNode, ControlFlowNode modificationNode
where
    // 确认存在对 locals() 返回字典的修改
    hasLocalsModification(modificationNode) and
    // 获取与控制流节点对应的 AST 节点
    astNode = modificationNode.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not astNode.getScope() instanceof ModuleScope
// 选择结果并附加警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."