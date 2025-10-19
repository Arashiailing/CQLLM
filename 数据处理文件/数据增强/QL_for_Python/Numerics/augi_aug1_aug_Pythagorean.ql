/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects potentially problematic hypotenuse calculations using the standard formula (a²+b²) that may cause numeric overflow
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

/**
 * Identifies expressions that compute the square of a value.
 * This includes both exponentiation with power 2 (x**2) and
 * self-multiplication (x*x).
 */
DataFlow::ExprNode squareOperation() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Check for exponentiation with power of 2
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Check for self-multiplication pattern
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

/**
 * Main query to detect problematic Pythagorean calculations.
 * Finds math.sqrt() calls that compute the hypotenuse using the
 * standard formula, which may lead to numeric overflow issues.
 */
from 
  DataFlow::CallCfgNode sqrtCallNode,     // The math.sqrt() function call
  BinaryExpr additionExpr,                // Addition expression inside the sqrt
  DataFlow::ExprNode leftOperand,         // First term in the addition
  DataFlow::ExprNode rightOperand         // Second term in the addition
where
  // Verify we're looking at a math.sqrt call
  sqrtCallNode = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Ensure the argument to sqrt is an addition operation
  sqrtCallNode.getArg(0).asExpr() = additionExpr and
  additionExpr.getOp() instanceof Add and
  
  // Extract the left and right operands of the addition
  leftOperand.asExpr() = additionExpr.getLeft() and
  rightOperand.asExpr() = additionExpr.getRight() and
  
  // Confirm both operands are square operations
  leftOperand.getALocalSource() = squareOperation() and
  rightOperand.getALocalSource() = squareOperation()
select sqrtCallNode, "Pythagorean calculation with sub-optimal numerics."