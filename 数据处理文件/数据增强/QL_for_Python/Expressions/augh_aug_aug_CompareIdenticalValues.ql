/**
 * @name Comparison of identical values
 * @description Detects redundant comparisons where a value is compared against itself,
 *              which usually indicates a logical error or unclear programming intent.
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

// Identify redundant comparisons while filtering out intentional cases
from RedundantComparison redundantComparison
where 
  // Skip constant comparisons which may represent intentional design patterns
  not redundantComparison.isConstant() 
  // Avoid false positives when 'self' might be accidentally omitted
  and not redundantComparison.maybeMissingSelf()
// Report findings with remediation guidance for floating-point comparisons
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."