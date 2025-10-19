/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations in Python 2 where both operands are integers,
 *              potentially leading to truncated results due to Python 2's division behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Detect division operations in Python 2 that might truncate the result
from BinaryExpr divisionOp, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant for Python 2, as later versions implement true division
  major_version() = 2 and
  exists(BinaryExprNode divExprNode, Value leftIntVal, Value rightIntVal |
    // Identify the division expression node and verify it's a division operation
    divExprNode = divisionOp.getAFlowNode() and
    divExprNode.getNode().getOp() instanceof Div and
    
    // Verify both operands are integers
    divExprNode.getLeft().pointsTo(leftIntVal, leftOperand) and
    leftIntVal.getClass() = ClassValue::int_() and
    divExprNode.getRight().pointsTo(rightIntVal, rightOperand) and
    rightIntVal.getClass() = ClassValue::int_() and
    
    // Exclude cases where division is exact (no remainder)
    not leftIntVal.(NumericValue).getIntValue() % rightIntVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules that import true division from __future__
    not divExprNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where the result is explicitly cast to int
    not exists(CallNode intCastCall |
      intCastCall = ClassValue::int_().getACall() and
      intCastCall.getAnArg() = divExprNode
    )
  )
select divisionOp, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"