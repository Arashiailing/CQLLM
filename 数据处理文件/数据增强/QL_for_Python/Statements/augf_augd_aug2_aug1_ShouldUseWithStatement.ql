/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that exclusively close a resource,
 *              which can be simplified using Python's 'with' statement for enhanced
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

// Determines if a method call performs a 'close' operation
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attr | 
        methodCall.getFunc() = attr and 
        attr.getName() = "close"
    ) 
}

// Checks if a finally block exclusively contains a single 'close' call
predicate isFinallyBlockWithOnlyClose(Try tryBlock, Call closeMethodCall) {
    exists(ExprStmt stmt |
        tryBlock.getAFinalstmt() = stmt and 
        stmt.getValue() = closeMethodCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate isContextManagerReference(ControlFlowNode node, ClassValue contextManagerClass) {
    exists(Value value | 
        node.pointsTo(value) and 
        value.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Finds context managers closed in finally blocks instead of using 'with'
from Call closeMethodCall, Try tryFinallyBlock, ClassValue contextManagerClass
where
    isFinallyBlockWithOnlyClose(tryFinallyBlock, closeMethodCall) and
    isCloseMethodCall(closeMethodCall) and
    exists(ControlFlowNode refNode | 
        refNode = closeMethodCall.getFunc().getAFlowNode().(AttrNode).getObject()
    |
        isContextManagerReference(refNode, contextManagerClass)
    )
select closeMethodCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()