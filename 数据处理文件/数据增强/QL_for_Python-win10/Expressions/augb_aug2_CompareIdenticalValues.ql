/**
 * @name Identical Value Comparison
 * @description Detects redundant comparisons where both operands are identical, potentially indicating unclear programming intent.
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

from RedundantComparison identicalComparison
where 
  not identicalComparison.isConstant() and 
  not identicalComparison.maybeMissingSelf()
select 
  identicalComparison, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."