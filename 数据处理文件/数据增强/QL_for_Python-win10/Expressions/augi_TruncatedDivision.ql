/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations with integer operands that may
 *              cause truncation of the result in Python 2 environments.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Find division expressions where truncation might occur
from BinaryExpr divisionOperation, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // Only relevant in Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode exprNode, Value leftType, Value rightType |
    // Connect the division expression to its flow node
    exprNode = divisionOperation.getAFlowNode() and
    // Confirm this is a division operation
    exprNode.getNode().getOp() instanceof Div and
    // Process left operand information
    exprNode.getLeft().pointsTo(leftType, leftArg) and
    leftType.getClass() = ClassValue::int_() and
    // Process right operand information
    exprNode.getRight().pointsTo(rightType, rightArg) and
    rightType.getClass() = ClassValue::int_() and
    // Exclude cases where division result would not be truncated (no remainder)
    not leftType.(NumericValue).getIntValue() % rightType.(NumericValue).getIntValue() = 0 and
    // Skip modules that enable true division via __future__ import
    not exprNode.getNode().getEnclosingModule().hasFromFuture("division") and
    // Filter out cases where result is explicitly converted to integer
    not exists(CallNode typeConversion |
      typeConversion = ClassValue::int_().getACall() and
      typeConversion.getAnArg() = exprNode
    )
  )
select divisionOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"