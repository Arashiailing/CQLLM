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

// Find division operations that may truncate results in Python 2
from BinaryExpr divExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only applicable to Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode divNode, Value leftInt, Value rightInt |
    // Basic division operation identification
    divNode = divExpr.getAFlowNode() and
    divNode.getNode().getOp() instanceof Div and
    
    // Integer operand verification
    divNode.getLeft().pointsTo(leftInt, leftOperand) and
    leftInt.getClass() = ClassValue::int_() and
    divNode.getRight().pointsTo(rightInt, rightOperand) and
    rightInt.getClass() = ClassValue::int_() and
    
    // Filter out exact divisions (no remainder)
    not leftInt.(NumericValue).getIntValue() % rightInt.(NumericValue).getIntValue() = 0 and
    
    // Exclusion criteria
    not divNode.getNode().getEnclosingModule().hasFromFuture("division") and
    not exists(CallNode intCastCall |
      intCastCall = ClassValue::int_().getACall() and
      intCastCall.getAnArg() = divNode
    )
  )
select divExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"