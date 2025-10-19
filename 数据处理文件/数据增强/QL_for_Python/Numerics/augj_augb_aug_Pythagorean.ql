/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Identifies potential numerical precision issues when computing hypotenuse length using basic mathematical formula
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

// Helper predicate to detect expressions that perform squaring operations
DataFlow::ExprNode computeSquareOperation() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Case 1: Exponentiation with power of 2 (e.g., base**2)
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication (e.g., base*base)
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

from 
  DataFlow::CallCfgNode sqrtCallNode,      // Call to math.sqrt()
  BinaryExpr additionExpr,                 // Addition expression inside sqrt
  DataFlow::ExprNode leftSquareTerm,       // First squared value in the addition
  DataFlow::ExprNode rightSquareTerm       // Second squared value in the addition
where
  // Verify the structure: math.sqrt(leftSquare + rightSquare)
  sqrtCallNode = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCallNode.getArg(0).asExpr() = additionExpr and
  
  // Confirm addition operation with two operands
  additionExpr.getOp() instanceof Add and
  leftSquareTerm.asExpr() = additionExpr.getLeft() and
  rightSquareTerm.asExpr() = additionExpr.getRight() and
  
  // Validate both operands are results of squaring operations
  leftSquareTerm.getALocalSource() = computeSquareOperation() and
  rightSquareTerm.getALocalSource() = computeSquareOperation()
select sqrtCallNode, "Pythagorean calculation with sub-optimal numerics."