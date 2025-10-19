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

/* Identify non-constant identical comparisons that don't involve missing self */
from RedundantComparison identicalValueComp
where 
  not identicalValueComp.isConstant() and 
  not identicalValueComp.maybeMissingSelf()

/* Generate alert with remediation guidance */
select identicalValueComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."