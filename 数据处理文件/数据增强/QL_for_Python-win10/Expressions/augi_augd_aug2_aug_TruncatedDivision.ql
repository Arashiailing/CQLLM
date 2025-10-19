/**
 * @name Result of integer division may be truncated
 * @description Detects division operations with integer operands that could truncate 
 *              the result in Python 2 due to floor division behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify division operations with potential truncation in Python 2
from BinaryExpr divisionExpr, ControlFlowNode leftIntOperand, ControlFlowNode rightIntOperand
where
  // Restrict analysis to Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode divisionNode, Value leftIntValue, Value rightIntValue |
    // Core division operation identification
    divisionNode = divisionExpr.getAFlowNode() and
    divisionNode.getNode().getOp() instanceof Div and
    
    // Verify both operands are integers
    divisionNode.getLeft().pointsTo(leftIntValue, leftIntOperand) and
    leftIntValue.getClass() = ClassValue::int_() and
    divisionNode.getRight().pointsTo(rightIntValue, rightIntOperand) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // Exclude exact divisions (no remainder)
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclusion criteria for false positives
    not divisionNode.getNode().getEnclosingModule().hasFromFuture("division") and
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = divisionNode
    )
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftIntOperand, "left", rightIntOperand, "right"