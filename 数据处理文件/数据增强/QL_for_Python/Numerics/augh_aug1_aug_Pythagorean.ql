/**
 * @name Sub-optimal Pythagorean calculation with potential overflow
 * @description Detects hypotenuse calculations using standard formula (sqrt(a²+b²)) 
 *              which may cause numerical overflow for large values
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

// Identifies expressions performing squaring operations
DataFlow::ExprNode squareExprNode() {
  exists(BinaryExpr binExpr | binExpr = result.asExpr() |
    // Case 1: Exponentiation with power 2 (e.g., x**2)
    (binExpr.getOp() instanceof Pow and binExpr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication (e.g., x*x)
    (binExpr.getOp() instanceof Mult and 
     binExpr.getRight().(Name).getId() = binExpr.getLeft().(Name).getId())
  )
}

// Main detection logic for vulnerable hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtCall,       // math.sqrt() invocation site
  BinaryExpr addExpr,                   // Addition expression within sqrt
  DataFlow::ExprNode leftOperand,       // Left term of the addition
  DataFlow::ExprNode rightOperand       // Right term of the addition
where
  // Verify math.sqrt call with addition argument
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCall.getArg(0).asExpr() = addExpr and
  
  // Confirm addition operation between two squared terms
  addExpr.getOp() instanceof Add and
  leftOperand.asExpr() = addExpr.getLeft() and
  rightOperand.asExpr() = addExpr.getRight() and
  
  // Both operands must originate from squaring operations
  leftOperand.getALocalSource() = squareExprNode() and
  rightOperand.getALocalSource() = squareExprNode()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."