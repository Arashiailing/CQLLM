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

// Identifies expressions performing square operations through exponentiation or self-multiplication
DataFlow::ExprNode squareOpNode() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Case 1: Exponentiation with power of 2 (e.g., x**2)
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication (e.g., x*x)
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

// Main detection logic for problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtCall,          // math.sqrt() invocation site
  BinaryExpr addExpr,                      // Addition expression inside sqrt
  DataFlow::ExprNode leftTerm,             // Left operand of addition
  DataFlow::ExprNode rightTerm             // Right operand of addition
where
  // Verify math.sqrt() call with addition argument
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCall.getArg(0).asExpr() = addExpr and
  
  // Confirm addition operation between two square terms
  addExpr.getOp() instanceof Add and
  leftTerm.asExpr() = addExpr.getLeft() and
  rightTerm.asExpr() = addExpr.getRight() and
  
  // Both operands originate from square operations
  leftTerm.getALocalSource() = squareOpNode() and
  rightTerm.getALocalSource() = squareOpNode()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."