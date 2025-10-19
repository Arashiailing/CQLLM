/**
 * @name Should use a 'with' statement
 * @description Detects 'try-finally' blocks that solely close a resource,
 *              which could be refactored using Python's 'with' statement for
 *              better code clarity and maintainability.
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

// Identifies method calls that perform resource closure
predicate is_close_operation(Call closureCall) { 
    exists(Attribute closureAttr | 
        closureCall.getFunc() = closureAttr and 
        closureAttr.getName() = "close"
    ) 
}

// Verifies if a finally block exclusively contains a single close operation
predicate is_single_close_in_finally(Try tryStmt, Call closureCall) {
    exists(ExprStmt closureStatement |
        tryStmt.getAFinalstmt() = closureStatement and 
        closureStatement.getValue() = closureCall and 
        strictcount(tryStmt.getAFinalstmt()) = 1
    )
}

// Checks if a control flow node references a context manager type
predicate references_context_manager(ControlFlowNode flowNode, ClassValue ctxManagerClass) {
    ctxManagerClass.isContextManager() and
    forall(Value obj | flowNode.pointsTo(obj) | obj.getClass() = ctxManagerClass)
}

// Locates context managers closed in finally blocks instead of using 'with'
from Call closureCall, Try tryStmt, ClassValue ctxManagerClass
where
    is_single_close_in_finally(tryStmt, closureCall) and
    is_close_operation(closureCall) and
    exists(ControlFlowNode targetFlowNode | 
        targetFlowNode = closureCall.getFunc().getAFlowNode().(AttrNode).getObject() and
        references_context_manager(targetFlowNode, ctxManagerClass)
    )
select closureCall,
    "Context-manager instance $@ is closed in finally block. Consider using 'with' statement.",
    ctxManagerClass, ctxManagerClass.getName()