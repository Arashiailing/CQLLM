/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Calculating the hypotenuse using the standard formula may cause numerical overflow.
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

/** Detects squaring operations using the power operator (x ** 2) */
DataFlow::ExprNode powerBasedSquare() {
  exists(BinaryExpr binaryExpr | binaryExpr = result.asExpr() |
    binaryExpr.getOp() instanceof Pow and 
    binaryExpr.getRight().(IntegerLiteral).getN() = "2"
  )
}

/** Detects squaring operations using multiplication (x * x) */
DataFlow::ExprNode multiplicationBasedSquare() {
  exists(BinaryExpr mulExpr | mulExpr = result.asExpr() |
    mulExpr.getOp() instanceof Mult and 
    mulExpr.getRight().(Name).getId() = mulExpr.getLeft().(Name).getId()
  )
}

/** Detects any squaring operation (power or multiplication) */
DataFlow::ExprNode anySquareOperation() { 
  result in [powerBasedSquare(), multiplicationBasedSquare()] 
}

from 
  DataFlow::CallCfgNode sqrtCall, 
  BinaryExpr additionExpr, 
  DataFlow::ExprNode leftSquaredTerm, 
  DataFlow::ExprNode rightSquaredTerm
where
  // Identify calls to math.sqrt
  sqrtCall = API::moduleImport("math").getMember("sqrt").getACall() and
  // Argument must be an addition expression
  sqrtCall.getArg(0).asExpr() = additionExpr and
  // Addition operator must be used
  additionExpr.getOp() instanceof Add and
  // Map operands to data flow nodes
  leftSquaredTerm.asExpr() = additionExpr.getLeft() and
  rightSquaredTerm.asExpr() = additionExpr.getRight() and
  // Both operands must be squaring operations
  leftSquaredTerm.getALocalSource() = anySquareOperation() and
  rightSquaredTerm.getALocalSource() = anySquareOperation()
select sqrtCall, "Pythagorean calculation with sub-optimal numerics."