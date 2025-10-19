/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects potential numerical overflow when calculating hypotenuse using standard formula
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

/**
 * Helper predicate that identifies expressions performing squaring operations.
 * This predicate matches two common patterns for squaring a value:
 * 1. Exponentiation with power of 2 (e.g., x**2)
 * 2. Multiplication of a value by itself (e.g., x*x)
 */
DataFlow::ExprNode squareOperationDetector() {
  exists(BinaryExpr expr | expr = result.asExpr() |
    // Pattern 1: Value raised to the power of 2
    (expr.getOp() instanceof Pow and expr.getRight().(IntegerLiteral).getN() = "2")
    or
    // Pattern 2: Value multiplied by itself
    (expr.getOp() instanceof Mult and 
     expr.getRight().(Name).getId() = expr.getLeft().(Name).getId())
  )
}

from 
  DataFlow::CallCfgNode sqrtFunctionCall,  // Represents the math.sqrt() function call
  BinaryExpr additionOperation,            // The addition expression inside the sqrt function
  DataFlow::ExprNode leftSquaredOperand,   // First operand of the addition (a squared value)
  DataFlow::ExprNode rightSquaredOperand   // Second operand of the addition (a squared value)
where
  // Verify the call is to math.sqrt function
  sqrtFunctionCall = API::moduleImport("math").getMember("sqrt").getACall() and
  
  // Extract the addition expression from the sqrt argument
  sqrtFunctionCall.getArg(0).asExpr() = additionOperation and
  
  // Confirm the operation is addition
  additionOperation.getOp() instanceof Add and
  
  // Map the addition operands to our variables
  leftSquaredOperand.asExpr() = additionOperation.getLeft() and
  rightSquaredOperand.asExpr() = additionOperation.getRight() and
  
  // Verify both operands are results of squaring operations
  leftSquaredOperand.getALocalSource() = squareOperationDetector() and
  rightSquaredOperand.getALocalSource() = squareOperationDetector()
select sqrtFunctionCall, "Pythagorean calculation with sub-optimal numerics."