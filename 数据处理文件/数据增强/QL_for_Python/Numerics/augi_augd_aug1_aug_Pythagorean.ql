/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula that may cause numerical overflow
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

// Identifies expressions that compute the square of a value
// This includes both exponentiation with power 2 (e.g., x**2)
// and self-multiplication (e.g., x*x)
DataFlow::ExprNode squaredValueNode() {
  exists(BinaryExpr binaryExpr | binaryExpr = result.asExpr() |
    // Case 1: Exponentiation with power of 2
    (binaryExpr.getOp() instanceof Pow and binaryExpr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication
    (binaryExpr.getOp() instanceof Mult and 
     binaryExpr.getRight().(Name).getId() = binaryExpr.getLeft().(Name).getId())
  )
}

// Main detection logic for problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtFunctionCall,   // math.sqrt() invocation site
  BinaryExpr sumOfSquaresExpr,             // Addition expression inside sqrt
  DataFlow::ExprNode firstSquareTerm,       // Left operand of addition
  DataFlow::ExprNode secondSquareTerm       // Right operand of addition
where
  // Verify math.sqrt() call with addition argument
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtFunctionCall.getArg(0).asExpr() = sumOfSquaresExpr and
  
  // Confirm addition operation between two square terms
  sumOfSquaresExpr.getOp() instanceof Add and
  firstSquareTerm.asExpr() = sumOfSquaresExpr.getLeft() and
  secondSquareTerm.asExpr() = sumOfSquaresExpr.getRight() and
  
  // Both operands originate from square operations
  firstSquareTerm.getALocalSource() = squaredValueNode() and
  secondSquareTerm.getALocalSource() = squaredValueNode()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."