/**
 * @name Should use a 'with' statement
 * @description Identifies try-finally blocks that exclusively close a resource, 
 *              which reduces code readability. Using 'with' statements is the 
 *              preferred approach for resource management in Python.
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

// Determines if a call invokes a 'close' method
predicate isCloseMethodCall(Call closeCall) { 
    exists(Attribute closeAttr | 
        closeCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Checks if a try block's finally clause contains exactly one statement: a close call
predicate hasOnlyCloseInFinally(Try tryBlock, Call closeCall) {
    exists(ExprStmt finalStmt |
        tryBlock.getAFinalstmt() = finalStmt and 
        finalStmt.getValue() = closeCall and 
        strictcount(tryBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate refersToContextManager(ControlFlowNode objectFlowNode, ClassValue contextManagerClass) {
    forex(Value pointedValue | 
        objectFlowNode.pointsTo(pointedValue) | 
        pointedValue.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call closeCall, Try tryBlock, ClassValue contextManagerClass
where
    hasOnlyCloseInFinally(tryBlock, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode objectFlowNode | 
        objectFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        refersToContextManager(objectFlowNode, contextManagerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()