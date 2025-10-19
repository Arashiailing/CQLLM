/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks that exclusively close a resource. 
 *              These patterns can be refactored to use Python's 'with' statement 
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

// Checks if the invocation targets a 'close' method
predicate isCloseMethodCall(Call closeInvocation) { 
    exists(Attribute closeAttr | 
        closeInvocation.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Verifies the finally block contains only a single close operation
predicate isSoleCloseInFinally(Try tryStatement, Call closeInvocation) {
    exists(ExprStmt closeStmt |
        tryStatement.getAFinalstmt() = closeStmt and 
        closeStmt.getValue() = closeInvocation and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Determines if a control flow node references a context manager instance
predicate refersToContextManager(ControlFlowNode objectNode, ClassValue contextManagerClass) {
    forex(Value targetValue | 
        objectNode.pointsTo(targetValue) | 
        targetValue.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Locates try-finally blocks with sole close operations on context managers
from Call closeInvocation, Try tryStatement, ClassValue contextManagerClass
where
    isSoleCloseInFinally(tryStatement, closeInvocation) and
    isCloseMethodCall(closeInvocation) and
    exists(ControlFlowNode objectNode | 
        objectNode = closeInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        refersToContextManager(objectNode, contextManagerClass)
    )
select closeInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()