/**
 * @name Comparison of identical values
 * @description Detects redundant comparisons where values are compared to themselves,
 *              often indicating logical errors or unclear implementation intent.
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

from RedundantComparison identicalComparison
where 
  // Exclude intentional constant comparisons to reduce noise
  not identicalComparison.isConstant()
  // Filter potential false positives from missing 'self' references
  and not identicalComparison.maybeMissingSelf()
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."