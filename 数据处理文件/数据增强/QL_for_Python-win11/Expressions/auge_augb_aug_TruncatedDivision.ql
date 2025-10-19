/**
 * @name Result of integer division may be truncated
 * @description Detects division operations where both arguments are integers,
 *              which may cause the result to be truncated in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify division expressions that may cause truncation in Python 2
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant for Python 2 (true division was implemented in later versions)
  major_version() = 2 and
  exists(BinaryExprNode divisionFlowNode, Value leftValue, Value rightValue |
    // Establish division operation node and verify it's a division operator
    divisionFlowNode = divisionExpr.getAFlowNode() and
    divisionFlowNode.getNode().getOp() instanceof Div and
    
    // Verify left operand is an integer type
    divisionFlowNode.getLeft().pointsTo(leftValue, leftOperand) and
    leftValue.getClass() = ClassValue::int_() and
    
    // Verify right operand is an integer type
    divisionFlowNode.getRight().pointsTo(rightValue, rightOperand) and
    rightValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division has no remainder (truncation has no effect)
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using `from __future__ import division` (true division enabled)
    not divisionFlowNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions (likely intentional behavior)
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = divisionFlowNode
    )
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"