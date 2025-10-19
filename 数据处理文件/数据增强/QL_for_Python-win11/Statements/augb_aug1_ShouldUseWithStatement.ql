/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that solely close a resource. These patterns
 *              can be simplified using Python's 'with' statement for improved readability
 *              and automatic resource management.
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

// Checks if the invocation targets a 'close' method
predicate is_close_method_call(Call closeMethodCall) { 
    exists(Attribute closeAttr | 
        closeMethodCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Verifies the finally block contains only a single close operation
predicate is_sole_close_in_finally(Try tryStmt, Call closeMethodCall) {
    exists(ExprStmt closeStatement |
        tryStmt.getAFinalstmt() = closeStatement and 
        closeStatement.getValue() = closeMethodCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Determines if a control flow node references a context manager instance
predicate refers_to_context_manager(ControlFlowNode objectFlowNode, ClassValue contextManagerCls) {
    forex(Value targetValue | 
        objectFlowNode.pointsTo(targetValue) | 
        targetValue.getClass() = contextManagerCls
    ) and
    contextManagerCls.isContextManager()
}

// Locates try-finally blocks with sole close operations on context managers
from Call closeCall, Try tryBlock, ClassValue contextManagerClass
where
    is_sole_close_in_finally(tryBlock, closeCall) and
    is_close_method_call(closeCall) and
    exists(ControlFlowNode objectFlowNode | 
        objectFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refers_to_context_manager(objectFlowNode, contextManagerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()