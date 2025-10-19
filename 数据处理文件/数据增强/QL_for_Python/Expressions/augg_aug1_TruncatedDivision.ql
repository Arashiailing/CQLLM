/**
 * @name Integer division result may be truncated in Python 2
 * @description Detects integer division operations in Python 2 that may truncate results.
 *              In Python 2, the '/' operator performs floor division when both operands
 *              are integers, which can lead to unexpected truncation of fractional parts.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify integer division operations that may produce truncated results
from BinaryExpr divisionOperation, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // Target only Python 2 environments where this behavior exists
  major_version() = 2 and
  
  // Verify the operation is a division with integer operands
  exists(BinaryExprNode binaryExprNode, Value leftNumValue, Value rightNumValue |
    binaryExprNode = divisionOperation.getAFlowNode() and
    binaryExprNode.getNode().getOp() instanceof Div and // Confirm division operator
    binaryExprNode.getLeft().pointsTo(leftNumValue, leftArg) and
    leftNumValue.getClass() = ClassValue::int_() and // Left operand is integer
    binaryExprNode.getRight().pointsTo(rightNumValue, rightArg) and
    rightNumValue.getClass() = ClassValue::int_() and // Right operand is integer
    
    // Exclude cases where division would have no remainder
    not leftNumValue.(NumericValue).getIntValue() % rightNumValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules that have enabled true division via future import
    not binaryExprNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where the result is explicitly converted to int
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryExprNode
    )
  )
select divisionOperation, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"