/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations where both operands are integers,
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

// Detect integer division operations that may truncate results
from BinaryExpr divisionOp, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // Restrict analysis to Python 2 (true division was introduced in Python 3)
  major_version() = 2 and
  exists(
    BinaryExprNode divNode, 
    Value leftIntVal, 
    Value rightIntVal
    |
    // Verify division operator and node relationship
    divNode = divisionOp.getAFlowNode() and
    divNode.getNode().getOp() instanceof Div and
    
    // Validate left operand is integer
    divNode.getLeft().pointsTo(leftIntVal, leftArg) and
    leftIntVal.getClass() = ClassValue::int_() and
    
    // Validate right operand is integer
    divNode.getRight().pointsTo(rightIntVal, rightArg) and
    rightIntVal.getClass() = ClassValue::int_() and
    
    // Exclude exact divisions (no truncation when remainder is zero)
    not leftIntVal.(NumericValue).getIntValue() % rightIntVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using future division imports
    not divNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions of division results
    not exists(CallNode intCastCall |
      intCastCall = ClassValue::int_().getACall() and
      intCastCall.getAnArg() = divNode
    )
  )
select divisionOp, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"