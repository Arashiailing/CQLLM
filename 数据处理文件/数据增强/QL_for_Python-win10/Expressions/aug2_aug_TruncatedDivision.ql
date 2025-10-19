/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations where both operands are integers,
 *              which may cause truncation in Python 2 due to floor division behavior.
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
from BinaryExpr divisionOperation, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // Only relevant for Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftIntValue, Value rightIntValue |
    // Get the AST node for the division operation
    binaryNode = divisionOperation.getAFlowNode() and
    // Verify the operator is division
    binaryNode.getNode().getOp() instanceof Div and
    
    // Check left operand is an integer
    binaryNode.getLeft().pointsTo(leftIntValue, leftArg) and
    leftIntValue.getClass() = ClassValue::int_() and
    
    // Check right operand is an integer
    binaryNode.getRight().pointsTo(rightIntValue, rightArg) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division has no remainder (exact division)
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using true division from __future__
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude cases where result is explicitly converted to int
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryNode
    )
  )
select divisionOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"