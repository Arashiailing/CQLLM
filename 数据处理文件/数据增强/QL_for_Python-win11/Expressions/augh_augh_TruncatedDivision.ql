/**
 * @name Integer division result truncation risk
 * @description Identifies division operations where both operands are integers,
 *              which may lead to truncated results in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// Find division expressions with integer operands that might truncate the result
from BinaryExpr divisionOperation, ControlFlowNode leftValueNode, ControlFlowNode rightValueNode
where
  // Only applicable in Python 2 (true division was introduced in later versions)
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftIntValue, Value rightIntValue |
    // Confirm division operator
    binaryNode = divisionOperation.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and
    
    // Check left operand type
    binaryNode.getLeft().pointsTo(leftIntValue, leftValueNode) and
    leftIntValue.getClass() = ClassValue::int_() and
    
    // Check right operand type
    binaryNode.getRight().pointsTo(rightIntValue, rightValueNode) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // Exclude cases where division results in no remainder (exact division)
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules that have imported future division
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer type conversions of the division result
    not exists(CallNode intTypeConversion |
      intTypeConversion = ClassValue::int_().getACall() and
      intTypeConversion.getAnArg() = binaryNode
    )
  )
select divisionOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftValueNode, "left", rightValueNode, "right"