/**
 * @name Should use a 'with' statement
 * @description Identifies code patterns where a 'try-finally' block is exclusively used 
 *              for resource cleanup, which could be simplified using a 'with' statement.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/should-use-with
 */

import python

// 检查给定的方法调用是否为资源关闭操作（即close方法）
predicate isCloseMethodCall(Call resourceCloseCall) { 
    exists(Attribute attribute | resourceCloseCall.getFunc() = attribute and attribute.getName() = "close") 
}

// 检查try-finally块的finally部分是否仅包含一个资源关闭调用
predicate hasOnlyCloseInFinally(Try tryFinallyBlock, Call resourceCloseCall) {
    exists(ExprStmt statement |
        tryFinallyBlock.getAFinalstmt() = statement and 
        statement.getValue() = resourceCloseCall and 
        strictcount(tryFinallyBlock.getAFinalstmt()) = 1
    )
}

// 检查控制流节点是否引用了一个上下文管理器类的实例
predicate refersToContextManager(ControlFlowNode resourceFlowNode, ClassValue contextManagerClass) {
    forex(Value value | resourceFlowNode.pointsTo(value) | value.getClass() = contextManagerClass) and
    contextManagerClass.isContextManager()
}

// 查找所有在finally块中仅包含close方法调用的代码，并建议使用'with'语句
from Call resourceCloseCall, Try tryFinallyBlock, ClassValue contextManagerClass
where
    // 确保finally块中只有一个close调用
    hasOnlyCloseInFinally(tryFinallyBlock, resourceCloseCall) and 
    // 确保该调用确实是close方法
    isCloseMethodCall(resourceCloseCall) and 
    // 确保close方法是在上下文管理器实例上调用
    exists(ControlFlowNode resourceFlowNode | 
        resourceFlowNode = resourceCloseCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refersToContextManager(resourceFlowNode, contextManagerClass)
    )
select resourceCloseCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()