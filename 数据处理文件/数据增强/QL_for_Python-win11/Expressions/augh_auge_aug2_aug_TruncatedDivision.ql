/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations where both operands are integers,
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
from BinaryExpr divisionExpr, ControlFlowNode leftArgNode, ControlFlowNode rightArgNode
where
  // Only relevant for Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode divisionNode, Value leftIntValue, Value rightIntValue |
    // Get the AST node for the division operation
    divisionNode = divisionExpr.getAFlowNode() and
    // Verify the operator is division
    divisionNode.getNode().getOp() instanceof Div and
    
    // Check left operand is an integer
    divisionNode.getLeft().pointsTo(leftIntValue, leftArgNode) and
    leftIntValue.getClass() = ClassValue::int_() and
    
    // Check right operand is an integer
    divisionNode.getRight().pointsTo(rightIntValue, rightArgNode) and
    rightIntValue.getClass() = ClassValue::int_()
  ) and
  // Exclude cases where division has no remainder (exact division)
  exists(BinaryExprNode divisionNode, Value leftIntValue, Value rightIntValue |
    divisionNode = divisionExpr.getAFlowNode() and
    divisionNode.getLeft().pointsTo(leftIntValue, _) and
    divisionNode.getRight().pointsTo(rightIntValue, _) and
    leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() != 0
  ) and
  // Exclude modules using true division from __future__
  not exists(Module mod | mod = divisionExpr.getEnclosingModule() and mod.hasFromFuture("division")) and
  // Exclude cases where result is explicitly converted to int
  not exists(CallNode intConversionCall |
    intConversionCall = ClassValue::int_().getACall() and
    intConversionCall.getAnArg() = divisionExpr.getAFlowNode()
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArgNode, "left", rightArgNode, "right"