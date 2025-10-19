/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks that only close a resource, which could be simplified
 *              using Python's 'with' statement for better readability and maintainability.
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
predicate is_close_method_call(Call methodCall) { 
    exists(Attribute attr | methodCall.getFunc() = attr and attr.getName() = "close") 
}

// 判断在finally块中是否只有一条语句且该语句是close方法的调用
predicate is_sole_close_in_finally(Try tryBlock, Call methodCall) {
    exists(ExprStmt statement |
        tryBlock.getAFinalstmt() = statement and 
        statement.getValue() = methodCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// 检查控制流节点是否指向上下文管理器类的实例
predicate refers_to_context_manager(ControlFlowNode flowNode, ClassValue contextManagerClass) {
    forex(Value pointedValue | flowNode.pointsTo(pointedValue) | pointedValue.getClass() = contextManagerClass) and
    contextManagerClass.isContextManager()
}

// 查找所有在finally块中仅包含close方法调用的代码，并建议使用'with'语句
from Call closeCall, Try tryBlock, ClassValue contextManagerClass
where
    is_sole_close_in_finally(tryBlock, closeCall) and
    is_close_method_call(closeCall) and
    exists(ControlFlowNode flowNode | 
        flowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refers_to_context_manager(flowNode, contextManagerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()