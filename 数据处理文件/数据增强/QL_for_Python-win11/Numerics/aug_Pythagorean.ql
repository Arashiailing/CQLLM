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

// Unified square operation detection covering both exponentiation and multiplication
DataFlow::ExprNode squareOperation() {
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
  DataFlow::CallCfgNode sqrtCall,    // math.sqrt() call site
  BinaryExpr addExpr,                // Addition expression inside sqrt
  DataFlow::ExprNode leftOperand,    // Left operand of addition
  DataFlow::ExprNode rightOperand    // Right operand of addition
where
  // Identify math.sqrt() call with addition argument
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCall.getArg(0).asExpr() = addExpr and
  
  // Addition operation between two square terms
  addExpr.getOp() instanceof Add and
  leftOperand.asExpr() = addExpr.getLeft() and
  rightOperand.asExpr() = addExpr.getRight() and
  
  // Both operands originate from square operations
  leftOperand.getALocalSource() = squareOperation() and
  rightOperand.getALocalSource() = squareOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."