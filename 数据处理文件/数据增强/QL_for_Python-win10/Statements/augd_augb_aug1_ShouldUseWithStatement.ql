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
predicate isCloseMethodCall(Call closeCall) { 
    exists(Attribute closeAttr | 
        closeCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Verifies the finally block contains only a single close operation
predicate isSoleCloseInFinally(Try tryBlock, Call closeCall) {
    exists(ExprStmt closeStmt |
        tryBlock.getAFinalstmt() = closeStmt and 
        closeStmt.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Determines if a control flow node references a context manager instance
predicate refersToContextManager(ControlFlowNode objFlowNode, ClassValue contextManagerCls) {
    forex(Value targetValue | 
        objFlowNode.pointsTo(targetValue) | 
        targetValue.getClass() = contextManagerCls
    ) and
    contextManagerCls.isContextManager()
}

// Locates try-finally blocks with sole close operations on context managers
from Call closeCall, Try tryBlock, ClassValue contextManagerCls
where
    isSoleCloseInFinally(tryBlock, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode objFlowNode | 
        objFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refersToContextManager(objFlowNode, contextManagerCls)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerCls, contextManagerCls.getName()