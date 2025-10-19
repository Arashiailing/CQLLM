/**
 * @name Comparison of identical values
 * @description Detects redundant comparisons where a value is compared to itself,
 *              typically indicating logical errors or unclear implementation intent.
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

from RedundantComparison identicalExpr
where 
  // Exclude constant comparisons which are often intentional
  not identicalExpr.isConstant() 
  // Filter cases where 'self' might be missing to reduce false positives
  and not identicalExpr.maybeMissingSelf()
select identicalExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."