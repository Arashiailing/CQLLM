/**
 * @name Should use a 'with' statement
 * @description Identifies 'try-finally' blocks containing only a single resource close operation
 *              that can be simplified using 'with' statements for improved readability.
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

// Identify try-finally blocks where the finally block contains exactly one statement
// that is a resource close operation on a context manager instance
from Call closeCall, Try tryFinally, ClassValue contextMgrClass
where
  // Condition 1: Finally block contains exactly one statement which is the close call
  exists(ExprStmt finalStmt |
    tryFinally.getAFinalstmt() = finalStmt and 
    finalStmt.getValue() = closeCall and 
    strictcount(tryFinally.getAFinalstmt()) = 1
  ) and
  // Condition 2: The call invokes a 'close' method
  exists(Attribute closeAttr |
    closeCall.getFunc() = closeAttr and 
    closeAttr.getName() = "close"
  ) and
  // Condition 3: The closed object is a context manager instance
  exists(ControlFlowNode objFlowNode | 
    objFlowNode = closeCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    exists(Value objValue | 
      objFlowNode.pointsTo(objValue) and 
      objValue.getClass() = contextMgrClass and
      contextMgrClass.isContextManager()
    )
  )
select closeCall,
    "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
    contextMgrClass, contextMgrClass.getName()