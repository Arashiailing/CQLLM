/**
 * @name Identical Value Comparison
 * @description Identifies redundant comparisons where both operands are identical,
 *              which may indicate unclear programming intent or logical errors.
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

from RedundantComparison redundantComparison
where 
  not redundantComparison.isConstant() and 
  not redundantComparison.maybeMissingSelf()
select 
  redundantComparison, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."