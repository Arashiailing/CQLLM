/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Calculating hypotenuse length using standard formula may cause numeric overflow.
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

// Unified detector for squaring operations (exponentiation or multiplication)
DataFlow::ExprNode squaringOperation() {
  exists(BinaryExpr mathOp | mathOp = result.asExpr() |
    // Case 1: Squaring via exponentiation operator (x**2)
    (mathOp.getOp() instanceof Pow and 
     mathOp.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Squaring via multiplication operator (x*x)
    (mathOp.getOp() instanceof Mult and 
     mathOp.getRight().(Name).getId() = mathOp.getLeft().(Name).getId())
  )
}

// Identify problematic Pythagorean calculations
from 
  DataFlow::CallCfgNode sqrtInvocation, 
  BinaryExpr addExpr, 
  DataFlow::ExprNode leftSquaredOp, 
  DataFlow::ExprNode rightSquaredOp
where
  // Verify math.sqrt() function call
  sqrtInvocation = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Confirm addition operation as first argument
  sqrtInvocation.getArg(0).asExpr() = addExpr and
  addExpr.getOp() instanceof Add and
  
  // Map operands to data flow nodes
  leftSquaredOp.asExpr() = addExpr.getLeft() and
  rightSquaredOp.asExpr() = addExpr.getRight() and
  
  // Verify both operands are squaring operations
  leftSquaredOp.getALocalSource() = squaringOperation() and
  rightSquaredOp.getALocalSource() = squaringOperation()
select sqrtInvocation, "Pythagorean calculation with sub-optimal numerics."