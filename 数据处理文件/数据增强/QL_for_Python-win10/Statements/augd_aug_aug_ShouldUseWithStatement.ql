/**
 * @name Use 'with' statement for resource management
 * @description Detects try-finally blocks that exclusively close a resource,
 *              which can be simplified using 'with' statements for improved
 *              readability and adherence to Python best practices.
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

from Call closingCall, Try tryFinallyBlock, ClassValue cmClass
where
  // Verify the call invokes a 'close' method
  exists(Attribute closingAttr | 
    closingCall.getFunc() = closingAttr and 
    closingAttr.getName() = "close"
  ) and
  // Ensure finally block contains only this close call
  exists(ExprStmt finallyStmt |
    tryFinallyBlock.getAFinalstmt() = finallyStmt and 
    finallyStmt.getValue() = closingCall and 
    strictcount(tryFinallyBlock.getAFinalstmt()) = 1
  ) and
  // Confirm the object being closed is a context manager
  exists(ControlFlowNode referencedNode | 
    referencedNode = closingCall.getFunc().getAFlowNode().(AttrNode).getObject() and
    forex(Value targetValue | 
      referencedNode.pointsTo(targetValue) | 
      targetValue.getClass() = cmClass
    ) and
    cmClass.isContextManager()
  )
select closingCall,
  "Instance of context-manager class $@ is closed in a finally block. Consider using 'with' statement.",
  cmClass, cmClass.getName()