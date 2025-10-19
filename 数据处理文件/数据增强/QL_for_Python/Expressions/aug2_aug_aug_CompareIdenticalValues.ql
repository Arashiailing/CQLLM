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

// Query to detect expressions where values are compared against themselves
from RedundantComparison identicalComparison
where 
  // Filter out constant comparisons as these may be intentional
  not identicalComparison.isConstant() and 
  // Exclude cases where 'self' might be missing to avoid false positives
  not identicalComparison.maybeMissingSelf()
// Output the identified comparison with a helpful warning message
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."