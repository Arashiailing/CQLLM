/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Identifies potential numerical overflow when computing hypotenuse 
 *              using the standard Pythagorean formula (sqrt(a² + b²))
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

// Helper predicate to detect expressions that compute the square of a value
DataFlow::ExprNode squareComputation() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Case 1: Value raised to the power of 2 (e.g., x**2)
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Value multiplied by itself (e.g., x*x)
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

from 
  DataFlow::CallCfgNode sqrtFunctionCall,  // Call to math.sqrt()
  BinaryExpr additionExpression,           // Addition expression within sqrt
  DataFlow::ExprNode firstSquareTerm,      // First squared operand
  DataFlow::ExprNode secondSquareTerm      // Second squared operand
where
  // Verify we're analyzing a math.sqrt call containing an addition
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtFunctionCall.getArg(0).asExpr() = additionExpression and
  
  // Validate the addition operation structure
  additionExpression.getOp() instanceof Add and
  firstSquareTerm.asExpr() = additionExpression.getLeft() and
  secondSquareTerm.asExpr() = additionExpression.getRight() and
  
  // Ensure both operands are results of squaring operations
  firstSquareTerm.getALocalSource() = squareComputation() and
  secondSquareTerm.getALocalSource() = squareComputation()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."