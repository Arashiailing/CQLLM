/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations where both operands are integers,
 *              potentially causing result truncation in Python 2 environments.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify division operations that may result in truncation in Python 2
from BinaryExpr divisionOperation, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // Restrict analysis to Python 2 where integer division truncates results
  major_version() = 2 and
  exists(BinaryExprNode binaryDivNode, Value leftIntValue, Value rightIntValue |
    // Associate the flow node with the division expression
    binaryDivNode = divisionOperation.getAFlowNode() and
    
    // Verify the operation is a division
    binaryDivNode.getNode().getOp() instanceof Div and
    
    // Analyze left operand - confirm it's an integer
    binaryDivNode.getLeft().pointsTo(leftIntValue, leftArg) and
    leftIntValue.getClass() = ClassValue::int_() and
    
    // Analyze right operand - confirm it's an integer
    binaryDivNode.getRight().pointsTo(rightIntValue, rightArg) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division results in no remainder
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using true division via future import
    not binaryDivNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions which indicate intentional behavior
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryDivNode
    )
  )
select divisionOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"