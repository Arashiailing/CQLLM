/**
 * @name Potential truncation in integer division (Python 2)
 * @description In Python 2, the division operator '/' applied to integers performs
 *              integer division, which truncates the fractional part. This query
 *              finds such divisions where truncation might be unintended.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify integer division operations in Python 2 that may cause truncation
from BinaryExpr divExpr, ControlFlowNode leftOperandNode, ControlFlowNode rightOperandNode
where
  // Only applicable in Python 2 (true division is default in Python 3)
  major_version() = 2 and
  exists(BinaryExprNode divNode, Value leftIntValue, Value rightIntValue |
    divNode = divExpr.getAFlowNode() and
    divNode.getNode().getOp() instanceof Div and // Confirm division operator
    divNode.getLeft().pointsTo(leftIntValue, leftOperandNode) and
    leftIntValue.getClass() = ClassValue::int_() and // Left operand is integer
    divNode.getRight().pointsTo(rightIntValue, rightOperandNode) and
    rightIntValue.getClass() = ClassValue::int_() and // Right operand is integer
    
    // Exclude cases where division yields no remainder (no truncation occurs)
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules with true division enabled via future import
    not divNode.getNode().getEnclosingModule().hasFromFuture("division")
  ) and
  // Exclude cases where result is explicitly cast to int (developer is aware)
  not exists(CallNode intCastCall |
    intCastCall = ClassValue::int_().getACall() and
    intCastCall.getAnArg() = divExpr.getAFlowNode()
  )
select divExpr, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperandNode, "left", rightOperandNode, "right"