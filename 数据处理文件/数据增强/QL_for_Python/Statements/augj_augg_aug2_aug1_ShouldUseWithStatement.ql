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

// Determines if a method call is a 'close' operation
predicate is_close_method_call(Call closeInvocation) { 
    exists(Attribute closeAttribute | 
        closeInvocation.getFunc() = closeAttribute and 
        closeAttribute.getName() = "close"
    ) 
}

// Verifies if a finally block contains only a single 'close' method call
predicate is_sole_close_in_finally(Try tryStmt, Call closeInvocation) {
    // First ensure there's exactly one statement in finally block
    strictcount(tryStmt.getAFinalstmt()) = 1 and
    // Then verify that single statement is the close call
    exists(ExprStmt closeStmt |
        tryStmt.getAFinalstmt() = closeStmt and 
        closeStmt.getValue() = closeInvocation
    )
}

// Checks if a control flow node references a context manager instance
predicate refers_to_context_manager(ControlFlowNode nodeInFlow, ClassValue contextManagerClass) {
    // For all values pointed to by the flow node
    forex(Value referencedValue | 
        nodeInFlow.pointsTo(referencedValue) | 
        referencedValue.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Locate context manager instances being closed in finally blocks
from Call closeInvocation, Try tryStmt, ClassValue contextManagerClass
where
    // Confirm the call is a close operation
    is_close_method_call(closeInvocation) and
    // Verify it's the only statement in finally block
    is_sole_close_in_finally(tryStmt, closeInvocation) and
    // Ensure the closed object is a context manager
    exists(ControlFlowNode nodeInFlow | 
        nodeInFlow = closeInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        refers_to_context_manager(nodeInFlow, contextManagerClass)
    )
select closeInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()