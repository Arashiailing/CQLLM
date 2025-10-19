/**
 * @name Sub-optimal Pythagorean calculation with potential overflow
 * @description Identifies hypotenuse computations using the standard mathematical formula (sqrt(a²+b²))
 *              that can lead to numerical overflow when dealing with large input values
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

// Detects expressions that perform squaring operations through either exponentiation or self-multiplication
DataFlow::ExprNode squaredExpressionNode() {
  exists(BinaryExpr binaryExpression | binaryExpression = result.asExpr() |
    // First pattern: Exponentiation operation with power of 2 (e.g., variable**2)
    (binaryExpression.getOp() instanceof Pow and binaryExpression.getRight().(IntegerLiteral).getN() = "2")
    or
    // Second pattern: Multiplication of a variable with itself (e.g., variable*variable)
    (binaryExpression.getOp() instanceof Mult and 
     binaryExpression.getRight().(Name).getId() = binaryExpression.getLeft().(Name).getId())
  )
}

// Main detection logic for identifying vulnerable Pythagorean theorem implementations
from 
  DataFlow::CallCfgNode sqrtFunctionCall,  // Represents the math.sqrt() function invocation
  BinaryExpr additionOperation,            // The addition operation inside the sqrt function
  DataFlow::ExprNode leftSquaredTerm,      // The left operand of the addition (a squared term)
  DataFlow::ExprNode rightSquaredTerm      // The right operand of the addition (a squared term)
where
  // Validate that we're analyzing a math.sqrt call containing an addition expression
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  sqrtFunctionCall.getArg(0).asExpr() = additionOperation and
  
  // Ensure the operation inside sqrt is an addition between two terms
  additionOperation.getOp() instanceof Add and
  leftSquaredTerm.asExpr() = additionOperation.getLeft() and
  rightSquaredTerm.asExpr() = additionOperation.getRight() and
  
  // Verify both operands of the addition are results of squaring operations
  leftSquaredTerm.getALocalSource() = squaredExpressionNode() and
  rightSquaredTerm.getALocalSource() = squaredExpressionNode()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."