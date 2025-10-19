/**
 * @name Should use a 'with' statement
 * @description Detects try-finally blocks that only close resources, which can be simplified 
 *              using 'with' statements for better readability and maintainability.
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

/**
 * Checks if a call invokes the 'close' method.
 */
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attribute | 
        methodCall.getFunc() = attribute and 
        attribute.getName() = "close"
    ) 
}

/**
 * Determines if a try statement's finally block contains exactly one statement,
 * which is the specified method call.
 */
predicate isOnlyStatementInFinally(Try tryStmt, Call methodCall) {
    exists(ExprStmt statement |
        tryStmt.getAFinalstmt() = statement and 
        statement.getValue() = methodCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Main query: Identify try-finally blocks with only close() calls
from Call closeCall, Try tryStatement, ClassValue contextManagerClass
where
    // Verify finally block contains only the close call
    isOnlyStatementInFinally(tryStatement, closeCall) and
    // Confirm the call is to a close method
    isCloseMethodCall(closeCall) and
    // Check the closed object is a context manager
    exists(ControlFlowNode objectNode | 
        objectNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        // Verify the object points to a context manager class
        forex(Value value | objectNode.pointsTo(value) | 
            value.getClass() = contextManagerClass
        ) and
        contextManagerClass.isContextManager()
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()