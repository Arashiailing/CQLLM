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

// Identify division operations in Python 2 that may truncate results
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only applicable in Python 2 where '/' does floor division for integers
  major_version() = 2 and
  
  // Check if this is a division operation with integer operands
  exists(BinaryExprNode binaryNode, Value leftVal, Value rightVal |
    // Verify this is a division operation
    binaryNode = divisionExpr.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and
    
    // Verify both operands are integers
    binaryNode.getLeft().pointsTo(leftVal, leftOperand) and
    leftVal.getClass() = ClassValue::int_() and
    binaryNode.getRight().pointsTo(rightVal, rightOperand) and
    rightVal.getClass() = ClassValue::int_() and
    
    // Ensure the division would actually truncate (has a remainder)
    not leftVal.(NumericValue).getIntValue() % rightVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules that have enabled true division via future import
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where the result is explicitly converted to int
    not exists(CallNode intCast |
      intCast = ClassValue::int_().getACall() and
      intCast.getAnArg() = binaryNode
    )
  )
select divisionExpr, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"