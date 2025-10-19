/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Calculating hypotenuse length using standard formula may cause overflow
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

// Identifies expressions performing square calculations
DataFlow::ExprNode squareOperation() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Detect exponentiation with power 2 (x**2)
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Detect self-multiplication (x*x)
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

// Detection logic for potentially problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtCallNode,      // math.sqrt() invocation
  BinaryExpr additionExpr,                 // Addition operation within sqrt
  DataFlow::ExprNode leftSquareTerm,       // First squared term
  DataFlow::ExprNode rightSquareTerm       // Second squared term
where
  // Verify math.sqrt() call with addition argument
  sqrtCallNode = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCallNode.getArg(0).asExpr() = additionExpr and
  
  // Confirm addition operation between two squared terms
  additionExpr.getOp() instanceof Add and
  leftSquareTerm.asExpr() = additionExpr.getLeft() and
  rightSquareTerm.asExpr() = additionExpr.getRight() and
  
  // Ensure both terms originate from square operations
  leftSquareTerm.getALocalSource() = squareOperation() and
  rightSquareTerm.getALocalSource() = squareOperation()
select sqrtCallNode, "Pythagorean calculation with sub-optimal numerics."