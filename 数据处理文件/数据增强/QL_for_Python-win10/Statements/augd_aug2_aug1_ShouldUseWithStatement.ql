/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks that only close a resource,
 *              which can be simplified by using Python's 'with' statement for improved
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
predicate isCloseMethodCall(Call closeCall) { 
    exists(Attribute closeAttr | 
        closeCall.getFunc() = closeAttr and 
        closeAttr.getName() = "close"
    ) 
}

// Checks if a finally block exclusively contains a single 'close' call
predicate isOnlyCloseInFinally(Try tryStmt, Call closeCall) {
    exists(ExprStmt stmt |
        tryStmt.getAFinalstmt() = stmt and 
        stmt.getValue() = closeCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Verifies if a control flow node references a context manager instance
predicate referencesContextManager(ControlFlowNode refNode, ClassValue managerClass) {
    exists(Value pointedValue | 
        refNode.pointsTo(pointedValue) and 
        pointedValue.getClass() = managerClass
    ) and
    managerClass.isContextManager()
}

// Finds context managers closed in finally blocks instead of using 'with'
from Call closeCall, Try tryStmt, ClassValue managerClass
where
    isOnlyCloseInFinally(tryStmt, closeCall) and
    isCloseMethodCall(closeCall) and
    exists(ControlFlowNode refNode | 
        refNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject()
    |
        referencesContextManager(refNode, managerClass)
    )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    managerClass, managerClass.getName()