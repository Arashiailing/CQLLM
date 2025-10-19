/**
 * @name Identical value comparison detection
 * @description Identifies code locations where a comparison is performed between identical values, potentially indicating unclear programming intent.
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

/* Identify comparisons between identical values, excluding constant expressions and potential missing self references */
from RedundantComparison identicalValueComparison
where 
  /* Filter out constant comparisons and those potentially missing self reference */
  not identicalValueComparison.isConstant() and 
  not identicalValueComparison.maybeMissingSelf()

/* Report the identified comparison with a remediation suggestion */
select identicalValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."