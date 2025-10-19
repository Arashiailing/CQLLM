/**
 * @name Identical value comparison detection
 * @description Identifies code locations where identical values are compared,
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

/* Identify non-constant redundant comparisons not related to missing self */
from RedundantComparison identicalComparison
where 
  not identicalComparison.isConstant() and 
  not identicalComparison.maybeMissingSelf()

/* Generate alert with remediation guidance */
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."