/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close a resource. 
 *              These patterns can be simplified using Python's 'with' statement 
 *              for enhanced readability and automatic resource management.
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

// Determines if a method call targets a 'close' operation
predicate is_close_method_call(Call closeCall) { 
    exists(Attribute closeAttr | 
        closeCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Verifies that a finally block contains only a single close operation
predicate is_sole_close_in_finally(Try tryBlock, Call closeCall) {
    exists(ExprStmt closeStmt |
        tryBlock.getAFinalstmt() = closeStmt and 
        closeStmt.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Checks if a control flow node references a context manager instance
predicate refers_to_context_manager(ControlFlowNode objectFlowNode, ClassValue contextManagerClass) {
    forex(Value targetValue | 
        objectFlowNode.pointsTo(targetValue) | 
        targetValue.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
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