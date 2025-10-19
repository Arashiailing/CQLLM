/**
 * @name Constant Expression Comparison
 * @description Identifies instances where two constant expressions are being compared. 
 *              Such comparisons yield predictable results at compile time, making them redundant.
 *              Replacing these with direct boolean values (True/False) enhances code clarity,
 *              readability, and maintainability. This query helps detect unnecessary comparisons,
 *              thereby improving overall code quality.
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

// Identify comparison operations between two constant expressions, excluding those used in assertions
from Compare constantComparison, Expr leftConstant, Expr rightConstant
where
  // Verify that the operation is a comparison with constant operands on both sides
  constantComparison.compares(leftConstant, _, rightConstant) and
  leftConstant.isConstant() and
  rightConstant.isConstant() and
  // Exclude comparisons within assert statements (explicit comparisons may be needed there)
  not exists(Assert assertStmt | 
    assertStmt.getTest() = constantComparison
  )
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."