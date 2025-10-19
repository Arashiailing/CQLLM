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

// Find division operations that may truncate results in Python 2
from BinaryExpr integerDivisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // Only relevant for Python 2 where integer division truncates
  major_version() = 2 and
  exists(BinaryExprNode divisionNode, Value leftIntVal, Value rightIntVal |
    // Map division expression to its AST node
    divisionNode = integerDivisionExpr.getAFlowNode() and
    
    // Verify division operator is used
    divisionNode.getNode().getOp() instanceof Div and
    
    // Validate left operand is integer
    divisionNode.getLeft().pointsTo(leftIntVal, leftOperand) and
    leftIntVal.getClass() = ClassValue::int_() and
    
    // Validate right operand is integer
    divisionNode.getRight().pointsTo(rightIntVal, rightOperand) and
    rightIntVal.getClass() = ClassValue::int_() and
    
    // Exclude exact divisions with no remainder
    not leftIntVal.(NumericValue).getIntValue() % rightIntVal.(NumericValue).getIntValue() = 0 and
    
    // Exclude modules using true division from __future__
    not divisionNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // Exclude explicit integer conversions of division result
    not exists(CallNode intConversion |
      intConversion = ClassValue::int_().getACall() and
      intConversion.getAnArg() = divisionNode
    )
  )
select integerDivisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"