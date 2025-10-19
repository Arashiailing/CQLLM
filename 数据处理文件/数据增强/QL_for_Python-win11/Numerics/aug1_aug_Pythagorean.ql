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

// Detects expressions that perform squaring operations
DataFlow::ExprNode squaringOperation() {
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
  DataFlow::CallCfgNode hypotenuseCalculation,  // math.sqrt() call site
  BinaryExpr sumExpression,                    // Addition expression inside sqrt
  DataFlow::ExprNode firstTerm,                // Left operand of addition
  DataFlow::ExprNode secondTerm                // Right operand of addition
where
  // Identify math.sqrt() call with addition argument
  hypotenuseCalculation = API::moduleImport("math").getMember("sqrt").getACall() and
  hypotenuseCalculation.getArg(0).asExpr() = sumExpression and
  
  // Addition operation between two square terms
  sumExpression.getOp() instanceof Add and
  firstTerm.asExpr() = sumExpression.getLeft() and
  secondTerm.asExpr() = sumExpression.getRight() and
  
  // Both operands originate from square operations
  firstTerm.getALocalSource() = squaringOperation() and
  secondTerm.getALocalSource() = squaringOperation()
select hypotenuseCalculation, "Pythagorean calculation with sub-optimal numerics."