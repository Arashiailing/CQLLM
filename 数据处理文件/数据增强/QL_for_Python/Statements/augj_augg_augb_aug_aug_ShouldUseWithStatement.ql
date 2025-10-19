/**
 * @name Should use a 'with' statement
 * @description Detects try-finally blocks that exclusively close a resource,
 *              which harms code readability. 'with' statements are the preferred
 *              pattern for resource management in Python.
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

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode node, ClassValue cmClass) {
    exists(Value value | 
        node.pointsTo(value) and 
        value.getClass() = cmClass
    ) and
    cmClass.isContextManager()
}

// Determines if a call invokes a 'close' method
predicate invokesCloseMethod(Call closeInvocation) { 
    exists(Attribute closeAttribute | 
        closeInvocation.getFunc() = closeAttribute and 
        closeAttribute.getName() = "close"
    ) 
}

// Checks if a try block's finally clause contains exactly one statement: a close call
predicate finallyContainsOnlyCloseCall(Try tryFinallyBlock, Call closeInvocation) {
    exists(ExprStmt finalStatement |
        tryFinallyBlock.getAFinalstmt() = finalStatement and 
        finalStatement.getValue() = closeInvocation and 
        strictcount(tryFinallyBlock.getAFinalstmt()) = 1
    )
}

// Identifies try-finally blocks that only close context managers
from Try tryFinallyBlock, Call closeInvocation, ClassValue cmClass
where
    finallyContainsOnlyCloseCall(tryFinallyBlock, closeInvocation) and
    invokesCloseMethod(closeInvocation) and
    exists(ControlFlowNode node | 
        node = closeInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(node, cmClass)
    )
select closeInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    cmClass, cmClass.getName()