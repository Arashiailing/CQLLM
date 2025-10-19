/**
 * @name Comparison of identical values
 * @description Identifies redundant comparisons where a value is compared against itself,
 *              typically indicating a logical error or unclear programming intent.
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

// Locate redundant comparisons while excluding intentional use cases
from RedundantComparison identicalExpr
where 
  // Exclude constant comparisons that may represent intentional design patterns
  not identicalExpr.isConstant() 
  // Filter false positives where 'self' might be accidentally omitted
  and not identicalExpr.maybeMissingSelf()
// Report findings with remediation guidance for floating-point comparisons
select identicalExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."