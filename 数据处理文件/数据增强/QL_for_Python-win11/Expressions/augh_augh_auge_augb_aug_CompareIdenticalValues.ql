/**
 * @name Identical value comparison detection
 * @description Detects comparisons between identical values, which often indicate unclear programming intent or logical errors.
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

/* Identify non-constant redundant comparisons unrelated to missing self */
from RedundantComparison redundantComp
where 
  /* Exclude constant comparisons (e.g., 5 == 5) */
  not redundantComp.isConstant() 
  /* Exclude cases where comparison might involve missing self parameter */
  and not redundantComp.maybeMissingSelf()

/* Generate alert with remediation guidance */
select redundantComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."