/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close a resource,
 *              which could be simplified using Python's 'with' statement for improved
 *              readability and maintainability.
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

// 判断方法调用是否为'close'操作
predicate is_close_method_call(Call closeCall) { 
    exists(Attribute closeAttr | 
        closeCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// 检查finally块是否仅包含一个'close'方法调用
predicate is_sole_close_in_finally(Try tryBlock, Call closeCall) {
    exists(ExprStmt closeStatement |
        tryBlock.getAFinalstmt() = closeStatement and 
        closeStatement.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// 验证控制流节点是否引用了上下文管理器实例
predicate refers_to_context_manager(ControlFlowNode flowNode, ClassValue managerClass) {
    forex(Value referencedObject | 
        flowNode.pointsTo(referencedObject) | 
        referencedObject.getClass() = managerClass
    ) and
    managerClass.isContextManager()
}

// 查找在finally块中关闭上下文管理器的实例
from Call closeCall, Try tryBlock, ClassValue managerClass
where
    is_close_method_call(closeCall) and
    is_sole_close_in_finally(tryBlock, closeCall) and
    exists(ControlFlowNode flowNode | 
        flowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refers_to_context_manager(flowNode, managerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerClass, managerClass.getName()