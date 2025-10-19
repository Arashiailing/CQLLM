/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Detects hypotenuse calculations using standard formula that may cause numerical overflow.
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

/** Identifies squaring operations using power operator (x ** 2) */
DataFlow::ExprNode powerBasedSquare() {
  exists(BinaryExpr powerExpr | powerExpr = result.asExpr() |
    powerExpr.getOp() instanceof Pow and 
    powerExpr.getRight().(IntegerLiteral).getN() = "2"
  )
}

/** Identifies squaring operations using multiplication (x * x) */
DataFlow::ExprNode multiplicationBasedSquare() {
  exists(BinaryExpr multExpr | multExpr = result.asExpr() |
    multExpr.getOp() instanceof Mult and 
    multExpr.getRight().(Name).getId() = multExpr.getLeft().(Name).getId()
  )
}

/** Combines all squaring operation patterns */
DataFlow::ExprNode anySquareOperation() { 
  result in [powerBasedSquare(), multiplicationBasedSquare()] 
}

from 
  DataFlow::CallCfgNode sqrtInvocation, 
  BinaryExpr sumExpr, 
  DataFlow::ExprNode leftSquareNode, 
  DataFlow::ExprNode rightSquareNode
where
  // Locate math.sqrt function calls
  sqrtInvocation = API::moduleImport("math").getMember("sqrt").getACall() and
  // Verify argument is addition operation
  sqrtInvocation.getArg(0).asExpr() = sumExpr and
  // Confirm addition operator usage
  sumExpr.getOp() instanceof Add and
  // Extract left operand as data flow node
  leftSquareNode.asExpr() = sumExpr.getLeft() and
  // Extract right operand as data flow node
  rightSquareNode.asExpr() = sumExpr.getRight() and
  // Validate both operands are squaring operations
  leftSquareNode.getALocalSource() = anySquareOperation() and
  rightSquareNode.getALocalSource() = anySquareOperation()
select sqrtInvocation, "Pythagorean calculation with sub-optimal numerics."