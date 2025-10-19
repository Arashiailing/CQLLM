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

// Detects squaring operation using exponentiation with power of 2
DataFlow::ExprNode squareUsingExponent() {
  exists(BinaryExpr exponentOperation | exponentOperation = result.asExpr() |
    exponentOperation.getOp() instanceof Pow and 
    exponentOperation.getRight().(IntegerLiteral).getN() = "2"
  )
}

// Detects squaring operation using self-multiplication (x * x)
DataFlow::ExprNode squareUsingMultiplication() {
  exists(BinaryExpr multiplicationOperation | multiplicationOperation = result.asExpr() |
    multiplicationOperation.getOp() instanceof Mult and 
    multiplicationOperation.getRight().(Name).getId() = multiplicationOperation.getLeft().(Name).getId()
  )
}

// Combines both methods to detect any squaring operation
DataFlow::ExprNode squaredValue() { 
  result = squareUsingExponent() or 
  result = squareUsingMultiplication() 
}

// Identify potentially problematic Pythagorean theorem implementations
from 
  DataFlow::CallCfgNode sqrtFunctionCall, 
  BinaryExpr sumExpression, 
  DataFlow::ExprNode firstOperand, 
  DataFlow::ExprNode secondOperand
where
  // Verify we're analyzing a math.sqrt() function call
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Check that the first argument is an addition operation
  sqrtFunctionCall.getArg(0).asExpr() = sumExpression and
  sumExpression.getOp() instanceof Add and
  
  // Connect the addition operands to data flow nodes
  firstOperand.asExpr() = sumExpression.getLeft() and
  secondOperand.asExpr() = sumExpression.getRight() and
  
  // Ensure both operands are results of squaring operations
  firstOperand.getALocalSource() = squaredValue() and
  secondOperand.getALocalSource() = squaredValue()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."