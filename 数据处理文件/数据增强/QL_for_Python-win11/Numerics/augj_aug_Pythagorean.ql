/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula that may cause overflow
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

// Identifies expressions performing square operations (x**2 or x*x)
DataFlow::ExprNode squareOperationNode() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Case 1: Exponentiation with literal 2 (e.g., x**2)
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication (e.g., x*x)
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

// Main detection logic for problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode hypotenuseCall,  // math.sqrt() call site
  BinaryExpr sumOfSquares,               // Addition expression inside sqrt
  DataFlow::ExprNode firstSquareTerm,    // Left operand of addition
  DataFlow::ExprNode secondSquareTerm    // Right operand of addition
where
  // Verify math.sqrt() call with addition argument
  hypotenuseCall = API::moduleImport("math").getMember("sqrt").getACall() and
  hypotenuseCall.getArg(0).asExpr() = sumOfSquares and
  
  // Check addition operation between two square terms
  sumOfSquares.getOp() instanceof Add and
  firstSquareTerm.asExpr() = sumOfSquares.getLeft() and
  secondSquareTerm.asExpr() = sumOfSquares.getRight() and
  
  // Ensure both operands are square operations
  firstSquareTerm.getALocalSource() = squareOperationNode() and
  secondSquareTerm.getALocalSource() = squareOperationNode()
select hypotenuseCall, "Pythagorean calculation with sub-optimal numerics."