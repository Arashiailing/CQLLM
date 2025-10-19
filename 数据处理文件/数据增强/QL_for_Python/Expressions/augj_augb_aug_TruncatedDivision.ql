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

// Identify division expressions that may truncate results in Python 2
from BinaryExpr divExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant for Python 2 (true division introduced in Python 3)
  major_version() = 2 and
  exists(BinaryExprNode divNode, Value leftIntVal, Value rightIntVal |
    // Establish connection between expression and its AST node
    divNode = divExpr.getAFlowNode() and
    divNode.getNode().getOp() instanceof Div and
    
    // Verify left operand is integer-typed
    divNode.getLeft().pointsTo(leftIntVal, leftOperand) and
    leftIntVal.getClass() = ClassValue::int_() and
    
    // Verify right operand is integer-typed
    divNode.getRight().pointsTo(rightIntVal, rightOperand) and
    rightIntVal.getClass() = ClassValue::int_() and
    
    // Exclude cases where division yields no remainder (no truncation occurs)
    not leftIntVal.(NumericValue).getIntValue() % rightIntVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using true division via future import
    not divNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions (indicates intentional truncation)
    not exists(CallNode intConvCall |
      intConvCall = ClassValue::int_().getACall() and
      intConvCall.getAnArg() = divNode
    )
  )
select divExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"