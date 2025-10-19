/**
 * @name Identical Value Comparison
 * @description Detects comparisons where both operands are identical, which may indicate unclear intent.
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

// Locate comparisons with identical operands that require analysis
from RedundantComparison identicalComparison
where 
  // Filter out literal constant comparisons (e.g., 5 == 5)
  not identicalComparison.isConstant()
  // Exclude potential 'self' omissions in method comparisons
  and not identicalComparison.maybeMissingSelf()
select 
  identicalComparison, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."