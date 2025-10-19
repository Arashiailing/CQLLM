import python

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

// Identify integer division operations that may produce truncated results
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Target only Python 2 environments where this behavior exists
  major_version() = 2 and
  
  // Verify the operation is a division with integer operands
  exists(BinaryExprNode binaryExprNode, Value leftIntValue, Value rightIntValue |
    // Check if the expression is a division operation
    binaryExprNode = divisionExpr.getAFlowNode() and
    binaryExprNode.getNode().getOp() instanceof Div and
    
    // Verify both operands are integers
    binaryExprNode.getLeft().pointsTo(leftIntValue, leftOperand) and
    leftIntValue.getClass() = ClassValue::int_() and
    binaryExprNode.getRight().pointsTo(rightIntValue, rightOperand) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division would have no remainder
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules that have enabled true division via future import
    not binaryExprNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where the result is explicitly converted to int
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryExprNode
    )
  )
select divisionExpr, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"