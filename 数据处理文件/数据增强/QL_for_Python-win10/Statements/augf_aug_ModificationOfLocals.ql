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

/**
 * 检查控制流节点是否引用了 locals() 函数的调用结果
 * locals() 函数返回当前作用域的局部变量字典
 */
predicate referencesLocalsCall(ControlFlowNode flowNode) { 
    flowNode.pointsTo(_, _, Value::named("locals").getACall()) 
}

/**
 * 检测对 locals() 返回字典的直接字典操作
 * 包括下标赋值（如 locals()['x'] = value）和删除操作（如 del locals()['x']）
 */
predicate isDirectDictionaryModification(ControlFlowNode modificationNode) {
    exists(SubscriptNode subscriptNode |
        subscriptNode = modificationNode and
        referencesLocalsCall(subscriptNode.getObject()) and
        (subscriptNode.isStore() or subscriptNode.isDelete())
    )
}

/**
 * 检测对 locals() 返回字典的修改方法调用
 * 包括会改变字典内容的方法：pop, popitem, update, clear
 */
predicate isMethodBasedModification(ControlFlowNode modificationNode) {
    exists(CallNode callNode, AttrNode attributeNode, string methodName |
        callNode = modificationNode and
        attributeNode = callNode.getFunction() and
        referencesLocalsCall(attributeNode.getObject(methodName)) and
        methodName in ["pop", "popitem", "update", "clear"]
    )
}

/**
 * 判断是否存在对 locals() 返回字典的任何修改操作
 * 包括直接字典操作和方法调用修改
 */
predicate performsLocalsDictionaryModification(ControlFlowNode modificationNode) {
    isDirectDictionaryModification(modificationNode) or
    isMethodBasedModification(modificationNode)
}

from AstNode astNode, ControlFlowNode modificationNode
where
    // 查找修改 locals() 返回字典的操作
    performsLocalsDictionaryModification(modificationNode) and
    // 获取与控制流节点对应的 AST 节点
    astNode = modificationNode.getNode() and
    // 排除模块级别作用域，因为在模块级别 locals() 等同于 globals()
    not astNode.getScope() instanceof ModuleScope
// 输出结果并附带警告信息
select astNode, "Modification of the locals() dictionary will have no effect on the local variables."