/**
 * @name Comparison of identical values
 * @description Identifies comparisons where an expression is compared against itself,
 *              which typically indicates logical errors, unclear code, or implementation mistakes.
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

// Main query logic to detect self-comparisons that are usually unintentional
from RedundantComparison identicalValueComparison
// Filtering conditions to reduce false positives and focus on meaningful issues:
where 
  // Exclude constant/literal comparisons as these are often intentional
  not identicalValueComparison.isConstant() and 
  // Avoid flagging cases where a missing 'self' reference might be the actual issue
  not identicalValueComparison.maybeMissingSelf()
// Output results with guidance for proper NaN testing when needed
select identicalValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."