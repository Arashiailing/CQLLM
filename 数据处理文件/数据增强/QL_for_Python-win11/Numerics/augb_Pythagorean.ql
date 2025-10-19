/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Calculating hypotenuse length using standard formula may cause numeric overflow.
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

// Detects squaring operation using exponentiation operator
DataFlow::ExprNode squareViaExponent() {
  exists(BinaryExpr powerOp | powerOp = result.asExpr() |
    powerOp.getOp() instanceof Pow and 
    powerOp.getRight().(IntegerLiteral).getN() = "2"
  )
}

// Detects squaring operation using multiplication operator
DataFlow::ExprNode squareViaMultiplication() {
  exists(BinaryExpr mulOp | mulOp = result.asExpr() |
    mulOp.getOp() instanceof Mult and 
    mulOp.getRight().(Name).getId() = mulOp.getLeft().(Name).getId()
  )
}

// Unified squaring operation detector (combines both detection methods)
DataFlow::ExprNode squaringOperation() { 
  result = squareViaExponent() or 
  result = squareViaMultiplication() 
}

// Identify problematic Pythagorean calculations
from 
  DataFlow::CallCfgNode sqrtCall, 
  BinaryExpr additionExpr, 
  DataFlow::ExprNode leftOperand, 
  DataFlow::ExprNode rightOperand
where
  // Verify math.sqrt() function call
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Confirm addition operation as first argument
  sqrtCall.getArg(0).asExpr() = additionExpr and
  additionExpr.getOp() instanceof Add and
  
  // Map operands to data flow nodes
  leftOperand.asExpr() = additionExpr.getLeft() and
  rightOperand.asExpr() = additionExpr.getRight() and
  
  // Verify both operands are squaring operations
  leftOperand.getALocalSource() = squaringOperation() and
  rightOperand.getALocalSource() = squaringOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."