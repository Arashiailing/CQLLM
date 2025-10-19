/**
 * @name Should use a 'with' statement
 * @description Using a 'try-finally' block to ensure only that a resource is closed makes code more
 *              difficult to read. Using 'with' statement is more idiomatic and readable.
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

/* 判断一个调用是否为资源的close方法 */
predicate isCloseCall(Call closeCall) { 
    exists(Attribute attr | closeCall.getFunc() = attr and attr.getName() = "close") 
}

/* 判断try语句的finally块中是否仅包含一个close方法调用 */
predicate hasOnlyCloseInFinally(Try tryStmt, Call closeCall) {
    exists(ExprStmt stmt |
        tryStmt.getAFinalstmt() = stmt and stmt.getValue() = closeCall and strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

/* 检查控制流节点是否指向上下文管理器类的实例 */
predicate refersToContextManager(ControlFlowNode flowNode, ClassValue contextClass) {
    forex(Value value | flowNode.pointsTo(value) | value.getClass() = contextClass) and
    contextClass.isContextManager()
}

/* 查找在finally块中仅包含close方法调用的代码，建议使用'with'语句替代 */
from Call closeCall, Try tryStmt, ClassValue contextClass, ControlFlowNode flowNode
where
    isCloseCall(closeCall) and /* 确认是close方法调用 */
    hasOnlyCloseInFinally(tryStmt, closeCall) and /* finally块中只有close调用 */
    flowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    refersToContextManager(flowNode, contextClass) /* 确认对象是上下文管理器 */
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.", /* 建议使用with语句 */
    contextClass, contextClass.getName() /* 上下文管理器类及其名称 */