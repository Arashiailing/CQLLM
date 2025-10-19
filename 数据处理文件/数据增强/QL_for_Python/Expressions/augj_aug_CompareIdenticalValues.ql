/**
 * @name Comparison of identical values
 * @description Detects comparisons where both operands are identical values,
 *              which often indicates a programming error or redundant code.
 * @kind problem
 * @tags reliability
 *       correctness
 *       readability
 *       convention
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-of-identical-expressions
 */

import python
import Expressions.RedundantComparison

from RedundantComparison identicalExprComparison
where 
  // Exclude constant comparisons as they might be intentional
  not identicalExprComparison.isConstant() and
  // Exclude comparisons that might be missing 'self' to reduce false positives
  not identicalExprComparison.maybeMissingSelf()
select identicalExprComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."