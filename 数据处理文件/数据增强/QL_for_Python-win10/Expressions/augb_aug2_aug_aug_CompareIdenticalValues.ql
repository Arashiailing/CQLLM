/**
 * @name Comparison of identical values
 * @description Identifies redundant comparisons where a value is compared to itself,
 *              which typically indicates a logical error or unclear intent.
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

// Main query to identify redundant value comparisons
from RedundantComparison redundantValueComparison
where 
  // Exclude constant comparisons as they are often intentional
  not redundantValueComparison.isConstant() and 
  // Filter out cases where 'self' might be missing to reduce false positives
  not redundantValueComparison.maybeMissingSelf()
// Report the identified redundant comparison with an informative message
select redundantValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."