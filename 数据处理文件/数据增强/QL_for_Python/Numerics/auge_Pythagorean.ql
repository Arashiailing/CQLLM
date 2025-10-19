/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula that may cause numeric overflow
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

// Detects squaring operations using power operator (x**2)
DataFlow::ExprNode powerSquare() {
  exists(BinaryExpr binExpr | binExpr = result.asExpr() |
    binExpr.getOp() instanceof Pow and 
    binExpr.getRight().(IntegerLiteral).getN() = "2"
  )
}

// Detects squaring operations using multiplication (x*x)
DataFlow::ExprNode multiplicationSquare() {
  exists(BinaryExpr binExpr | binExpr = result.asExpr() |
    binExpr.getOp() instanceof Mult and 
    binExpr.getRight().(Name).getId() = binExpr.getLeft().(Name).getId()
  )
}

// Combines both types of squaring operations
DataFlow::ExprNode anySquareOperation() { 
  result in [powerSquare(), multiplicationSquare()] 
}

// Main query: Identify problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtCall, 
  BinaryExpr additionExpr, 
  DataFlow::ExprNode leftSquaredOperand, 
  DataFlow::ExprNode rightSquaredOperand
where
  // Identify math.sqrt function call
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  // Verify first argument is an addition expression
  sqrtCall.getArg(0).asExpr() = additionExpr and
  // Confirm addition operator is used
  additionExpr.getOp() instanceof Add and
  // Map operands to data flow nodes
  leftSquaredOperand.asExpr() = additionExpr.getLeft() and
  rightSquaredOperand.asExpr() = additionExpr.getRight() and
  // Verify both operands are squaring operations
  leftSquaredOperand.getALocalSource() = anySquareOperation() and
  rightSquaredOperand.getALocalSource() = anySquareOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."