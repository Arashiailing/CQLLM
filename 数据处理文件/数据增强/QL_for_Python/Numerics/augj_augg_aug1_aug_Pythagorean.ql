/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula that may cause numeric overflow
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

// Identifies expressions performing square calculations (x**2 or x*x)
DataFlow::ExprNode squareOperation() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Case 1: Exponentiation with power 2
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

// Detects problematic hypotenuse calculations using math.sqrt(a² + b²)
from 
  DataFlow::CallCfgNode sqrtCall,  // math.sqrt() invocation node
  BinaryExpr addExpr,              // Addition operation within sqrt
  DataFlow::ExprNode leftSquare,   // First squared term
  DataFlow::ExprNode rightSquare   // Second squared term
where
  // Verify math.sqrt call with addition argument
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCall.getArg(0).asExpr() = addExpr and
  
  // Confirm addition operation between two terms
  addExpr.getOp() instanceof Add and
  leftSquare.asExpr() = addExpr.getLeft() and
  rightSquare.asExpr() = addExpr.getRight() and
  
  // Ensure both terms are square operations
  leftSquare.getALocalSource() = squareOperation() and
  rightSquare.getALocalSource() = squareOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."