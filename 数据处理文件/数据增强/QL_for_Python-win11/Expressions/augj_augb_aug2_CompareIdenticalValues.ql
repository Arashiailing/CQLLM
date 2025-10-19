/**
 * @name Identical Value Comparison
 * @description Detects comparisons where both operands are identical, which is redundant and may indicate unclear programming intent.
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

from RedundantComparison redundantComp
where 
  // Exclude constant comparisons which are typically intentional
  not redundantComp.isConstant() 
  and 
  // Exclude cases where missing 'self' might cause false positives
  not redundantComp.maybeMissingSelf()
select 
  redundantComp, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."