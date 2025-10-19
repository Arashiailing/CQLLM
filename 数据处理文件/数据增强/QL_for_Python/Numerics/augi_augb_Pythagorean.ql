/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula (a² + b²)^0.5 that may cause numeric overflow.
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

// Unified detection for squaring operations (exponentiation or multiplication)
DataFlow::ExprNode squaringOperation() { 
  exists(BinaryExpr binExpr | binExpr = result.asExpr() |
    // Case 1: Squaring via exponentiation (x**2)
    (binExpr.getOp() instanceof Pow and 
     binExpr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Squaring via multiplication (x*x)
    (binExpr.getOp() instanceof Mult and 
     binExpr.getRight().(Name).getId() = binExpr.getLeft().(Name).getId())
  )
}

// Identify problematic Pythagorean calculations
from 
  DataFlow::CallCfgNode sqrtCall, 
  BinaryExpr sumExpression, 
  DataFlow::ExprNode firstSquaredTerm, 
  DataFlow::ExprNode secondSquaredTerm
where
  // Verify math.sqrt() function call
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Confirm addition operation as first argument
  sqrtCall.getArg(0).asExpr() = sumExpression and
  sumExpression.getOp() instanceof Add and
  
  // Map operands to data flow nodes
  firstSquaredTerm.asExpr() = sumExpression.getLeft() and
  secondSquaredTerm.asExpr() = sumExpression.getRight() and
  
  // Verify both operands are squaring operations
  firstSquaredTerm.getALocalSource() = squaringOperation() and
  secondSquaredTerm.getALocalSource() = squaringOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."