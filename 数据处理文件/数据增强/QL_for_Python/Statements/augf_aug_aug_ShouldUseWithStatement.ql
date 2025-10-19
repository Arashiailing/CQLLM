/**
 * @name Should use a 'with' statement
 * @description Detects try-finally blocks that solely close a resource, 
 *              which harms code readability. Using 'with' statements is the 
 *              recommended approach for resource management in Python.
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

// Checks if a call invokes a 'close' method on an object
predicate isCloseMethodInvocation(Call closeInvocation) { 
    exists(Attribute closeAttribute | 
        closeInvocation.getFunc() = closeAttribute and 
        closeAttribute.getName() = "close"
    ) 
}

// Verifies if a try block's finally clause contains exactly one close call
predicate hasSingleCloseInFinally(Try tryStmt, Call closeInvocation) {
    exists(ExprStmt finalStatement |
        tryStmt.getAFinalstmt() = finalStatement and 
        finalStatement.getValue() = closeInvocation and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Determines if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode objectRef, ClassValue mgrClass) {
    forex(Value targetValue | 
        objectRef.pointsTo(targetValue) | 
        targetValue.getClass() = mgrClass
    ) and
    mgrClass.isContextManager()
}

// Identifies try-finally blocks that exclusively close context managers
from Call closeInvocation, Try tryStmt, ClassValue mgrClass
where
    hasSingleCloseInFinally(tryStmt, closeInvocation) and
    isCloseMethodInvocation(closeInvocation) and
    exists(ControlFlowNode objectRef | 
        objectRef = closeInvocation.getFunc().getAFlowNode().(AttrNode).getObject() and
        referencesContextManager(objectRef, mgrClass)
    )
select closeInvocation,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    mgrClass, mgrClass.getName()