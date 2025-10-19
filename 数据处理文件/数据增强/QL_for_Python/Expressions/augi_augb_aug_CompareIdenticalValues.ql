/**
 * @name Identical value comparison detection
 * @description Detects comparisons where operands are identical, potentially indicating unclear logic
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

/* Identify redundant comparison expressions */
from RedundantComparison redundantExpr

/* Apply exclusion filters to minimize false positives */
where 
  /* Exclude constant value comparisons */
  not redundantExpr.isConstant() 
  /* Exclude cases where 'self' might be missing */
  and not redundantExpr.maybeMissingSelf()

/* Report findings with contextual warning message */
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."