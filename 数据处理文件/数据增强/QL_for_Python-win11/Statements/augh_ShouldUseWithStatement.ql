/**
 * @name Should use a 'with' statement
 * @description Detects code patterns where a 'try-finally' block is used only to ensure 
 *              resource cleanup, which could be simplified with a 'with' statement.
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

// 判断调用是否为close方法
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attribute | methodCall.getFunc() = attribute and attribute.getName() = "close") 
}

// 判断try块的finally块中是否只有一条语句且该语句是close方法的调用
predicate hasOnlyCloseInFinally(Try tryStmt, Call closeCall) {
    exists(ExprStmt statement |
        tryStmt.getAFinalstmt() = statement and statement.getValue() = closeCall and strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// 判断控制流节点是否指向上下文管理器类的实例
predicate refersToContextManager(ControlFlowNode flowNode, ClassValue contextManagerClass) {
    forex(Value value | flowNode.pointsTo(value) | value.getClass() = contextManagerClass) and
    contextManagerClass.isContextManager()
}

// 查找所有在finally块中仅包含close方法调用的代码，并建议使用'with'语句
from Call closeCall, Try tryStmt, ClassValue contextManagerClass
where
    hasOnlyCloseInFinally(tryStmt, closeCall) and // 检查finally块中是否只有一条语句且该语句是close方法的调用
    isCloseMethodCall(closeCall) and // 检查调用是否为close方法
    exists(ControlFlowNode flowNode | 
        flowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refersToContextManager(flowNode, contextManagerClass) // 检查控制流节点是否指向上下文管理器类的实例
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.", // 提示信息
    contextManagerClass, contextManagerClass.getName() // 选择上下文管理器类及其名称