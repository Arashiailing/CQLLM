/**
 * @name Identical value comparison detection
 * @description Detects code locations where a comparison is made between identical values, which might indicate unclear programming intent.
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

/* Find redundant comparisons that are not constant and not missing self */
from RedundantComparison redundantComparison
where 
  not redundantComparison.isConstant() and 
  not redundantComparison.maybeMissingSelf()

/* Report the redundant comparison with a helpful message */
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."