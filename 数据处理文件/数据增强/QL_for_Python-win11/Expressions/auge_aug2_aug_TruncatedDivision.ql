/**
 * @name Result of integer division may be truncated
 * @description Detects division operations where both operands are integers,
 *              potentially causing truncation in Python 2 due to floor division behavior.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Identify division operations that may truncate results in Python 2
from BinaryExpr divOperation, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant for Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode divNode, Value leftIntVal, Value rightIntVal |
    // Get the AST node for the division operation
    divNode = divOperation.getAFlowNode() and
    // Verify the operator is division
    divNode.getNode().getOp() instanceof Div and
    
    // Check left operand is an integer
    divNode.getLeft().pointsTo(leftIntVal, leftOperand) and
    leftIntVal.getClass() = ClassValue::int_() and
    
    // Check right operand is an integer
    divNode.getRight().pointsTo(rightIntVal, rightOperand) and
    rightIntVal.getClass() = ClassValue::int_() and
    
    // Exclude cases where division has no remainder (exact division)
    not leftIntVal.(NumericValue).getIntValue() % rightIntVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using true division from __future__
    not divNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where result is explicitly converted to int
    not exists(CallNode intCastCall |
      intCastCall = ClassValue::int_().getACall() and
      intCastCall.getAnArg() = divNode
    )
  )
select divOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"