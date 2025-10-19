/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Identifies hypotenuse calculations using standard formula (sqrt(a² + b²)) 
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

// Detects expressions performing squaring operations through either exponentiation 
// or self-multiplication patterns commonly used in Pythagorean calculations
DataFlow::ExprNode squareCalculationNode() {
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
  DataFlow::CallCfgNode sqrtFunctionCall,    // math.sqrt() function invocation
  BinaryExpr additionExpression,             // Addition operation inside sqrt
  DataFlow::ExprNode leftSquaredTerm,        // Left operand (a²) of the addition
  DataFlow::ExprNode rightSquaredTerm        // Right operand (b²) of the addition
where
  // Verify math.sqrt() call containing an addition expression as argument
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtFunctionCall.getArg(0).asExpr() = additionExpression and
  
  // Confirm the expression inside sqrt is an addition operation
  additionExpression.getOp() instanceof Add and
  leftSquaredTerm.asExpr() = additionExpression.getLeft() and
  rightSquaredTerm.asExpr() = additionExpression.getRight() and
  
  // Both operands must be results of squaring operations
  leftSquaredTerm.getALocalSource() = squareCalculationNode() and
  rightSquaredTerm.getALocalSource() = squareCalculationNode()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."