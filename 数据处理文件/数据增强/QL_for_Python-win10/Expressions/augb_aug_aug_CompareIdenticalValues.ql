/**
 * @name Comparison of identical values
 * @description Detects redundant comparisons where a variable/expression is compared against itself,
 *              which often indicates programming errors, unclear logic, or incorrect implementation.
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

import python  // Core Python analysis library providing language-specific constructs
import Expressions.RedundantComparison  // Specialized module for identifying redundant comparison patterns

// Query that identifies self-comparisons which are typically unintentional
from RedundantComparison redundantComparison
// Apply exclusion criteria to minimize false positive results:
where 
  // Filter out literal/constant comparisons as these may be intentional
  not redundantComparison.isConstant() and 
  // Prevent false alarms in cases where 'self' reference might be missing
  not redundantComparison.maybeMissingSelf()
// Report findings with contextual guidance for proper NaN testing
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."