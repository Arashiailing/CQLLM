/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects potential numeric overflow in hypotenuse calculations using standard Pythagorean formula.
 * @kind problem
 * @tags accuracy
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/pythagorean
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Identifies squaring through exponentiation operator (base**2)
DataFlow::ExprNode exponentiationSquare() {
  exists(BinaryExpr powerExpr | powerExpr = result.asExpr() |
    powerExpr.getOp() instanceof Pow and 
    powerExpr.getRight().(IntegerLiteral).getN() = "2"
  )
}

// Identifies squaring through multiplication (operand*operand)
DataFlow::ExprNode multiplicationSquare() {
  exists(BinaryExpr mulExpr | mulExpr = result.asExpr() |
    mulExpr.getOp() instanceof Mult and 
    mulExpr.getRight().(Name).getId() = mulExpr.getLeft().(Name).getId()
  )
}

// Unified detection for any squaring operation
DataFlow::ExprNode anySquareOperation() { 
  result = exponentiationSquare() or 
  result = multiplicationSquare() 
}

// Detects problematic Pythagorean calculations in sqrt calls
from 
  DataFlow::CallCfgNode sqrtCallNode, 
  BinaryExpr additionOperation, 
  DataFlow::ExprNode leftSquaredOperand, 
  DataFlow::ExprNode rightSquaredOperand
where
  // Validate math.sqrt() function call
  sqrtCallNode = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Verify addition expression as sqrt argument
  sqrtCallNode.getArg(0).asExpr() = additionOperation and
  additionOperation.getOp() instanceof Add and
  
  // Map addition operands to data flow nodes
  leftSquaredOperand.asExpr() = additionOperation.getLeft() and
  rightSquaredOperand.asExpr() = additionOperation.getRight() and
  
  // Confirm both operands are squaring operations
  leftSquaredOperand.getALocalSource() = anySquareOperation() and
  rightSquaredOperand.getALocalSource() = anySquareOperation()
select sqrtCallNode, "Pythagorean calculation with sub-optimal numerics."