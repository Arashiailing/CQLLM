/**
 * @name Comparison of constants
 * @description Identifies comparisons between two constant expressions. Such comparisons
 *              have predetermined results at compile time. Replacing them with their
 *              actual boolean values (True or False) improves code clarity, readability,
 *              and maintainability. This query helps detect unnecessary comparisons
 *              to enhance overall code quality.
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

// Identify comparison operations between constant expressions that are not used in assertions
from Compare constantComparison, Expr leftConstantOperand, Expr rightConstantOperand
where
  // Verify the operation is a comparison with constant operands on both sides
  constantComparison.compares(leftConstantOperand, _, rightConstantOperand) and
  // Ensure both operands are constant expressions
  leftConstantOperand.isConstant() and
  rightConstantOperand.isConstant() and
  // Exclude comparisons used in assertion statements (explicit comparisons may be needed there)
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."