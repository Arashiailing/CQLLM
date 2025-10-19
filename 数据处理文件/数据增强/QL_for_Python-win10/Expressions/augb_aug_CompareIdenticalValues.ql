/**
 * @name Identical value comparison detection
 * @description Identifies comparisons where values are the same, which may indicate unclear intent.
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
from RedundantComparison identicalComparison

/* Apply filters to reduce false positives */
where 
  not identicalComparison.isConstant() and 
  not identicalComparison.maybeMissingSelf()

/* Report findings with appropriate warning message */
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."