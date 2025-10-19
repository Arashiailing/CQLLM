/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks with a single resource close operation
 *              that can be simplified using 'with' statements for better readability.
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

// Determines if the given call invokes a method named 'close'
predicate isCloseMethodCall(Call methodCall) { 
    exists(Attribute attribute | 
        methodCall.getFunc() = attribute and 
        attribute.getName() = "close"
    ) 
}

// Checks if a try statement's finally block contains exactly one close call
predicate isFinallyBlockWithSingleCloseCall(Try tryStatement, Call closeMethodCall) {
    exists(ExprStmt statement |
        tryStatement.getAFinalstmt() = statement and 
        statement.getValue() = closeMethodCall and 
        strictcount(tryStatement.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node points to a context manager instance
predicate flowNodeReferencesContextManager(ControlFlowNode node, ClassValue contextManagerClass) {
    exists(Value value | node.pointsTo(value) | 
        value.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryStmt, ClassValue cls
where
    isFinallyBlockWithSingleCloseCall(tryStmt, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode objFlowNode | 
        objFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        flowNodeReferencesContextManager(objFlowNode, cls)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    cls, cls.getName()