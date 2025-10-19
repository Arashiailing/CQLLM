/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects potential numerical overflow when calculating hypotenuse using standard formula
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

// Helper predicate to identify expressions that compute the square of a value
DataFlow::ExprNode squaredValueOperation() {
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
  DataFlow::CallCfgNode hypotenuseCalculation,  // Call to math.sqrt()
  BinaryExpr sumExpression,                    // Addition expression within sqrt
  DataFlow::ExprNode firstSquaredTerm,         // First squared operand
  DataFlow::ExprNode secondSquaredTerm         // Second squared operand
where
  // Verify we're looking at a math.sqrt call containing an addition
  hypotenuseCalculation = API::moduleImport("math").getMember("sqrt").getACall() and
  hypotenuseCalculation.getArg(0).asExpr() = sumExpression and
  
  // Confirm the addition operation structure
  sumExpression.getOp() instanceof Add and
  firstSquaredTerm.asExpr() = sumExpression.getLeft() and
  secondSquaredTerm.asExpr() = sumExpression.getRight() and
  
  // Ensure both operands are results of squaring operations
  firstSquaredTerm.getALocalSource() = squaredValueOperation() and
  secondSquaredTerm.getALocalSource() = squaredValueOperation()
select hypotenuseCalculation, "Pythagorean calculation with sub-optimal numerics."