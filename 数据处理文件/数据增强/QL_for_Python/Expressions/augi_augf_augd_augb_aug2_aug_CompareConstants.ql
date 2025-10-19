/**
 * @name Comparison of constants
 * @description Identifies constant-to-constant comparisons that always evaluate 
 *              to the same boolean result. These can be replaced with literal 
 *              True/False to improve code readability.
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

// Locate comparison operations between constant expressions
from Compare constantCompare, Expr leftExpr, Expr rightExpr
where
  // Establish the comparison relationship between operands
  constantCompare.compares(leftExpr, _, rightExpr) and
  // Verify both operands are constant values
  leftExpr.isConstant() and
  rightExpr.isConstant() and
  // Exclude intentional constant comparisons in assert statements
  not exists(Assert assertStmt | assertStmt.getTest() = constantCompare)
select constantCompare, "Comparison of constants; use 'True' or 'False' instead."