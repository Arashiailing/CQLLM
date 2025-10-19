/**
 * @name Comparison of identical values
 * @description Detects logical issues where a variable or expression is compared against itself.
 *              Such comparisons are always true or false and usually indicate programming errors
 *              or unclear code intentions. For NaN checks, use cmath.isnan() instead.
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

import python  // Core Python library for code analysis
import Expressions.RedundantComparison  // Module for detecting redundant comparison expressions

// Define filtering conditions to exclude false positives
predicate isValidIdenticalComparison(RedundantComparison comparison) {
  // Skip constant comparisons as they are typically intentional
  not comparison.isConstant() and
  // Exclude cases where 'self' might be missing to reduce noise
  not comparison.maybeMissingSelf()
}

// Main query logic to find and report problematic self-comparisons
from RedundantComparison identicalValueComparison
where 
  // Apply our filtering criteria to ensure meaningful results
  isValidIdenticalComparison(identicalValueComparison)
// Output the identified issue with appropriate remediation guidance
select identicalValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."