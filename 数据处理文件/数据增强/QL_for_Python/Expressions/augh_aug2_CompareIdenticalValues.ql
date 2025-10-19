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

// Identify identical value comparisons that are not constant and not missing self
from RedundantComparison identicalValueComparison
where 
  // Exclude constant comparisons (e.g., 5 == 5)
  not identicalValueComparison.isConstant()
  // Exclude cases where 'self' might be missing in method comparisons
  and not identicalValueComparison.maybeMissingSelf()
select 
  identicalValueComparison, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."