/**
 * @name Identical value comparison detection
 * @description Identifies locations where identical values are compared, potentially indicating unclear programming logic.
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

/* Identify redundant comparisons that are neither constant expressions nor potential missing self cases */
from RedundantComparison redundantComparison
where 
  not redundantComparison.isConstant() 
  and not redundantComparison.maybeMissingSelf()

/* Generate alert with remediation guidance */
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."