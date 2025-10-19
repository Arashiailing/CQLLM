/**
 * @name Identical value comparison detection
 * @description Identifies comparisons between identical values that may indicate unclear programming intent or logical errors.
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

/* Identify redundant comparisons between identical values */
from RedundantComparison identicalComparison
where 
  /* Exclude constant comparisons (e.g., 5 == 5) */
  not identicalComparison.isConstant() 
  /* Exclude cases potentially involving missing self parameter */
  and not identicalComparison.maybeMissingSelf()

/* Generate alert with remediation guidance */
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."