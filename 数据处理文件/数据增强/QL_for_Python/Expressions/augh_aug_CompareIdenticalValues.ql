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

// Define filtering conditions to reduce false positives
// Condition 1: Exclude constant comparisons as they may be intentional
predicate isNotConstantComparison(RedundantComparison expr) {
  not expr.isConstant()
}

// Condition 2: Exclude comparisons that might be missing 'self' parameter
predicate isNotMissingSelfComparison(RedundantComparison expr) {
  not expr.maybeMissingSelf()
}

// Main query: Find redundant comparisons that meet our criteria
from RedundantComparison redundantExpr
where 
  isNotConstantComparison(redundantExpr) and 
  isNotMissingSelfComparison(redundantExpr)
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."