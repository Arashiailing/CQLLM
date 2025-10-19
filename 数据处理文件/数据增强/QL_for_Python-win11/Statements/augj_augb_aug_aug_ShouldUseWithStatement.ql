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
predicate invokesCloseMethod(Call resourceCloseCall) { 
    exists(Attribute closeMethodAttr | 
        resourceCloseCall.getFunc() = closeMethodAttr and 
        closeMethodAttr.getName() = "close"
    ) 
}

// Checks if a try block's finally clause contains exactly one statement: a close call
predicate finallyContainsOnlyCloseCall(Try tryFinallyBlock, Call resourceCloseCall) {
    exists(ExprStmt finallyStatement |
        tryFinallyBlock.getAFinalstmt() = finallyStatement and 
        finallyStatement.getValue() = resourceCloseCall and 
        strictcount(tryFinallyBlock.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode objectFlowNode, ClassValue contextManagerClass) {
    exists(Value pointedValue | 
        objectFlowNode.pointsTo(pointedValue) and 
        pointedValue.getClass() = contextManagerClass
    ) and
    contextManagerClass.isContextManager()
}

// Identifies try-finally blocks that only close context managers
from Call resourceCloseCall, Try tryFinallyBlock, ClassValue contextManagerClass
where
    // Verify finally block contains only close call
    finallyContainsOnlyCloseCall(tryFinallyBlock, resourceCloseCall) and
    // Confirm the call is to a close method
    invokesCloseMethod(resourceCloseCall) and
    // Ensure the closed object is a context manager
    exists(ControlFlowNode objectFlowNode | 
        objectFlowNode = resourceCloseCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(objectFlowNode, contextManagerClass)
    )
select resourceCloseCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextManagerClass, contextManagerClass.getName()