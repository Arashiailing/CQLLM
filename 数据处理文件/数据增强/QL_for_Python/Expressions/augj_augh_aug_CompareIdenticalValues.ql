/**
 * @name Comparison of identical values
 * @description Detects comparisons where both operands are the same value, 
 *              which often indicates unclear programming intent or potential bugs.
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

/**
 * Filters out redundant comparisons that are either constant expressions
 * or potentially missing 'self' parameter, as these cases often represent
 * intentional behavior or require special handling.
 */
predicate isValidRedundantComparison(RedundantComparison expr) {
  not expr.isConstant() and
  not expr.maybeMissingSelf()
}

from RedundantComparison redundantComparison
where isValidRedundantComparison(redundantComparison)
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."