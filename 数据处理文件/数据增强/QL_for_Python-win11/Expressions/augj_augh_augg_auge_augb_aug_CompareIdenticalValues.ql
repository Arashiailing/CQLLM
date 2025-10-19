/**
 * @name Identical Value Comparison Detection
 * @description This query identifies locations in Python code where identical values are compared,
 *              which could indicate unclear programming logic or potential bugs.
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

/* 
 * Find redundant comparisons that are:
 * 1. Not constant (to avoid flagging intentional constant comparisons)
 * 2. Not potentially missing 'self' (to avoid false positives in class methods)
 */
from RedundantComparison identicalValueComparison
where 
  not identicalValueComparison.isConstant() and 
  not identicalValueComparison.maybeMissingSelf()

/* Report findings with remediation guidance for floating-point NaN checks */
select identicalValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."