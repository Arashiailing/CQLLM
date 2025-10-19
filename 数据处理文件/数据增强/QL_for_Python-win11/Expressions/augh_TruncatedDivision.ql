/**
 * @name Result of integer division may be truncated
 * @description Detects division operations where both operands are integers,
 *              potentially causing truncation in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify division expressions with integer operands that may truncate results
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant in Python 2 (true division was implemented in later versions)
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftValue, Value rightValue |
    // Verify division operator
    binaryNode = divisionExpr.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and
    
    // Analyze left operand
    binaryNode.getLeft().pointsTo(leftValue, leftOperand) and
    leftValue.getClass() = ClassValue::int_() and
    
    // Analyze right operand
    binaryNode.getRight().pointsTo(rightValue, rightOperand) and
    rightValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division yields no remainder
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using future division imports
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions of the result
    not exists(CallNode intConversion |
      intConversion = ClassValue::int_().getACall() and
      intConversion.getAnArg() = binaryNode
    )
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"