/**
 * @name Comparison of constants
 * @description Detects comparison operations between two constant expressions that always evaluate to the same result.
 *              Such comparisons should be replaced with their actual boolean values (True or False) to enhance code clarity.
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/comparison-of-constants
 */

import python

// This query finds comparison operations where both sides are constants
from Compare constantComparisonOp, Expr leftOperand, Expr rightOperand
where
  // Check that the operation compares two expressions and both are constants
  constantComparisonOp.compares(leftOperand, _, rightOperand) and
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // Exclude comparisons in assert statements as they may be intentionally used for documentation
  not exists(Assert assertionStatement | assertionStatement.getTest() = constantComparisonOp)
select constantComparisonOp, "Comparison of constants; use 'True' or 'False' instead."