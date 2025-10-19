/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula (sqrt(a² + b²)) 
 *              that may cause numerical overflow for large input values
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

// Identifies expressions performing squaring operations through either exponentiation 
// or self-multiplication patterns commonly used in Pythagorean calculations
DataFlow::ExprNode squaredValueNode() {
  exists(BinaryExpr binaryExpr | binaryExpr = result.asExpr() |
    // Case 1: Exponentiation with power of 2 (e.g., x**2)
    (binaryExpr.getOp() instanceof Pow and binaryExpr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Case 2: Self-multiplication (e.g., x*x)
    (binaryExpr.getOp() instanceof Mult and 
     binaryExpr.getRight().(Name).getId() = binaryExpr.getLeft().(Name).getId())
  )
}

// Main detection logic for problematic hypotenuse calculations
from 
  DataFlow::CallCfgNode sqrtCall,          // math.sqrt() function invocation
  BinaryExpr addExpr,                      // Addition operation inside sqrt
  DataFlow::ExprNode leftSquared,          // Left operand (a²) of the addition
  DataFlow::ExprNode rightSquared          // Right operand (b²) of the addition
where
  // Verify math.sqrt() call containing an addition expression as argument
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtCall.getArg(0).asExpr() = addExpr and
  
  // Confirm the expression inside sqrt is an addition operation
  addExpr.getOp() instanceof Add and
  leftSquared.asExpr() = addExpr.getLeft() and
  rightSquared.asExpr() = addExpr.getRight() and
  
  // Both operands must be results of squaring operations
  leftSquared.getALocalSource() = squaredValueNode() and
  rightSquared.getALocalSource() = squaredValueNode()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."